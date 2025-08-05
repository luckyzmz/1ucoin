// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract OneUCoin is VRFConsumerBase, Ownable {
    IERC20 public usdt;
    IERC20 public odc;
    IUniswapV2Router02 public quickSwapRouter;
    AggregatorV3Interface public priceFeed;

    address public targetToken;
    string public targetSymbol;
    uint256 public totalShares;
    uint256 public sharesSold;
    uint256 public constant SHARE_PRICE = 1e6; // 1 USDT (6 decimals)
    uint256 public constant FEE_PERCENTAGE = 5; // 5% platform fee
    address[] public participants;
    mapping(address => uint256) public userShares;
    bool public drawActive;
    address public winner;

    bytes32 internal keyHash;
    uint256 internal vrfFee;
    uint256 public randomResult;

    event DrawStarted(address targetToken, string targetSymbol, uint256 totalShares);
    event SharePurchased(address user, uint256 shares);
    event DrawEnded(address winner, uint256 amount);
    event ODCdistributed(address user, uint256 odcAmount);
    event Swapped(address token, uint256 usdtAmount, uint256 tokenAmount);

    constructor(
        address _usdt,
        address _odc,
        address _quickSwapRouter,
        address _priceFeed,
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint256 _vrfFee
    ) VRFConsumerBase(_vrfCoordinator, _link) Ownable(msg.sender) {
        usdt = IERC20(_usdt);
        odc = IERC20(_odc);
        quickSwapRouter = IUniswapV2Router02(_quickSwapRouter);
        priceFeed = AggregatorV3Interface(_priceFeed);
        keyHash = _keyHash;
        vrfFee = _vrfFee;
        drawActive = false;
    }

    function startDraw(address _targetToken, string memory _targetSymbol, address _priceFeed) external onlyOwner {
        require(!drawActive, "Draw already active");
        targetToken = _targetToken;
        targetSymbol = _targetSymbol;
        priceFeed = AggregatorV3Interface(_priceFeed);
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 1e8, "Token price must be > 1 USDT");
        totalShares = uint256(price) / 1e8;
        sharesSold = 0;
        participants = new address[](0);
        drawActive = true;
        winner = address(0);
        emit DrawStarted(_targetToken, _targetSymbol, totalShares);
    }

    function purchaseShares(uint256 _shares) external {
        require(drawActive, "No active draw");
        require(_shares > 0, "Must purchase at least 1 share");
        require(sharesSold + _shares <= totalShares, "Exceeds available shares");
        uint256 usdtAmount = _shares * SHARE_PRICE;
        require(usdt.transferFrom(msg.sender, address(this), usdtAmount), "USDT transfer failed");
        userShares[msg.sender] += _shares;
        sharesSold += _shares;
        participants.push(msg.sender);
        emit SharePurchased(msg.sender, _shares);
        if (sharesSold == totalShares) {
            requestRandomness(keyHash, vrfFee);
        }
    }

    function fulfillRandomness(bytes32, uint256 randomness) internal override {
        randomResult = randomness;
        selectWinner();
    }

    function selectWinner() internal {
        require(drawActive, "No active draw");
        require(sharesSold == totalShares, "Draw not complete");
        uint256 winnerIndex = randomResult % participants.length;
        winner = participants[winnerIndex];
        distributePrize();
    }

    function distributePrize() internal {
        drawActive = false;
        uint256 totalUsdt = totalShares * SHARE_PRICE;
        uint256 fee = (totalUsdt * FEE_PERCENTAGE) / 100;
        uint256 prizeUsdt = totalUsdt - fee;
        usdt.transfer(owner(), fee);

        usdt.approve(address(quickSwapRouter), prizeUsdt);
        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] = targetToken;
        uint256[] memory amounts = quickSwapRouter.swapExactTokensForTokens(
            prizeUsdt,
            0,
            path,
            winner,
            block.timestamp + 300
        );
        emit Swapped(targetToken, prizeUsdt, amounts[1]);

        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] != winner) {
                uint256 odcAmount = userShares[participants[i]] * 1e18;
                odc.transfer(participants[i], odcAmount);
                emit ODCdistributed(participants[i], odcAmount);
            }
            userShares[participants[i]] = 0;
        }
        emit DrawEnded(winner, amounts[1]);
    }

    function getDrawStatus() external view returns (
        address _targetToken,
        string memory _targetSymbol,
        uint256 _totalShares,
        uint256 _sharesSold,
        bool _drawActive,
        address _winner
    ) {
        return (targetToken, targetSymbol, totalShares, sharesSold, drawActive, winner);
    }

    function emergencyStop() external onlyOwner {
        drawActive = false;
    }

    function withdrawLink() external onlyOwner {
        IERC20(link).transfer(owner(), IERC20(link).balanceOf(address(this)));
    }
}