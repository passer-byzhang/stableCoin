// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./Kerosene.sol";
import "./StakerFactory.sol";

//for uniswap v3
import "../dependencies/INonfungiblePositionManager.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IERC20Minimal.sol";

contract Staker is IERC721Receiver{
    using Math for uint256;
    //using SafeERC20 for IERC20;
    // Info of each user.
    struct UserInfo {
        uint256 tokenId; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 liquidity;
        //
        // We do some fancy math here. Basically, any point in time, the amount of SUSHIs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accSushiPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accSushiPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    // Info of each pool.
    struct PoolInfo {
        uint256 lastRewardBlock; // Last block number that SUSHIs distribution occurs.
        uint256 accKeroPerShare; // Accumulated SUSHIs per share, times 1e12. See below.
        // The REWARD TOKEN!
        Kerosene kero;
        // SUSHI tokens created per block.
        uint256 keroPerBlock;
        //for uniswap v3
        INonfungiblePositionManager nonfungiblePositionManager;
        int24 lowTick;
        int24 upTick;
        // The block number when SUSHI mining starts.
        uint256 startBlock;
        uint256 endBlock;
        address token0;
        address token1;
        uint24 fee;
        StakerFactory factory;
        uint256 totalLiquidity;
    }

    PoolInfo public poolInfo;

    // Bonus muliplier for early sushi makers.
    uint256 public constant BONUS_MULTIPLIER = 10;

    // Info of each user that stakes LP tokens.
    mapping(address => UserInfo) public userInfo;

    event Deposit(
        address indexed user,
        uint256 indexed tokenId,
        uint256 amount
    );
    event Withdraw(
        address indexed user,
        uint256 indexed tokenId,
        uint256 amount
    );
    event Harvest(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 tokenId);

    constructor(StakerFactory.StakeDeployedStruct memory params) {
        poolInfo.kero = params.kero;
        poolInfo.keroPerBlock = params.keroPerBlock;
        poolInfo.nonfungiblePositionManager = params.nonfungiblePositionManager;
        poolInfo.lowTick = params.lowTick;
        poolInfo.upTick = params.upTick;
        poolInfo.startBlock = params.startBlock;
        poolInfo.endBlock = params.endBlock;
        poolInfo.token0 = params.token0;
        poolInfo.token1 = params.token1;
        poolInfo.fee = params.fee;
        poolInfo.factory = params.factory;
        poolInfo.lastRewardBlock = params.startBlock;
    }

    modifier nftEligibe(uint256 tokenId) {
        (
            ,
            ,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            ,
            ,
            ,
            ,

        ) = poolInfo.nonfungiblePositionManager.positions(tokenId);
        require(token0 == poolInfo.token0, "token0 is not the same");
        require(token1 == poolInfo.token1, "token1 is not the same");
        require(fee == poolInfo.fee, "fee is not the same");
        require(tickLower == poolInfo.lowTick, "tickLower is not the same");
        require(tickUpper == poolInfo.upTick, "tickUpper is not the same");
        address staker = StakerFactory(poolInfo.factory).userToStaker(msg.sender);
        require(staker == address(0), "user is already staking");
        _;
    }

    modifier onlyOnProcessing() {
        require(block.number >= poolInfo.startBlock, "only started");
        require(block.number <= poolInfo.endBlock, "only processing");
        _;
    }



    // View function to see pending SUSHIs on frontend.
    function pendingKero(address account) external view returns (uint256) {
        UserInfo storage user = userInfo[account];
        uint256 accKeroPerShare = poolInfo.accKeroPerShare;
        uint256 rewardBlock = block.number > poolInfo.endBlock
            ? poolInfo.endBlock
            : block.number;
        if (
            rewardBlock > poolInfo.lastRewardBlock &&
            poolInfo.totalLiquidity != 0
        ) {
            uint256 keroReward = poolInfo.keroPerBlock;
            accKeroPerShare =
                accKeroPerShare +
                ((keroReward * 1e12) / poolInfo.totalLiquidity);
        }
        return
            (user.liquidity * poolInfo.accKeroPerShare) /
            1e12 -
            user.rewardDebt;
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool() public {
        uint256 rewardBlock = block.number > poolInfo.endBlock
            ? poolInfo.endBlock
            : block.number;
        if (rewardBlock <= poolInfo.lastRewardBlock) {
            return;
        }
        if (poolInfo.totalLiquidity == 0) {
            poolInfo.lastRewardBlock = rewardBlock;
            return;
        }
        uint256 keroReward = poolInfo.keroPerBlock;
        poolInfo.factory.dropToStaker(keroReward);
        poolInfo.accKeroPerShare =
            poolInfo.accKeroPerShare +
            ((keroReward * 1e12) / poolInfo.totalLiquidity);
        poolInfo.lastRewardBlock = rewardBlock;
    }

    // Deposit LP tokens to MasterChef for SUSHI allocation.
    function stake(
        uint256 tokenId
    ) public onlyOnProcessing nftEligibe(tokenId) {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        (
            ,
            ,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            ,
            ,
            ,

        ) = poolInfo.nonfungiblePositionManager.positions(tokenId);
        poolInfo.nonfungiblePositionManager.safeTransferFrom(
            address(msg.sender),
            address(this),
            tokenId
        );
        user.liquidity = liquidity;
        user.rewardDebt = (user.liquidity * poolInfo.accKeroPerShare) / 1e12;

        StakerFactory(poolInfo.factory).setUserToStaker(
            msg.sender,
            tokenId,
            address(this),
            true
        );
        emit Deposit(msg.sender, tokenId, liquidity);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 tokenId) public {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        uint256 liquidity = user.liquidity;
        uint256 pending = (user.liquidity * (poolInfo.accKeroPerShare)) /
            (1e12) -
            (user.rewardDebt);
        safeKeroTransfer(msg.sender, pending);
        user.liquidity = 0;
        user.rewardDebt = (user.liquidity * poolInfo.accKeroPerShare) / 1e12;
        poolInfo.nonfungiblePositionManager.safeTransferFrom(
            address(this),
            address(msg.sender),
            tokenId
        );
        StakerFactory(poolInfo.factory).setUserToStaker(
            msg.sender,
            tokenId,
            address(this),
            false
        );
        emit Withdraw(msg.sender, tokenId, liquidity);
    }

    function harvest() public {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        uint256 pending = (user.liquidity * (poolInfo.accKeroPerShare)) /
            (1e12) -
            (user.rewardDebt);
        safeKeroTransfer(msg.sender, pending);
        user.rewardDebt = (user.liquidity * poolInfo.accKeroPerShare) / 1e12;
        emit Harvest(msg.sender, pending);
    }



    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 tokenId) public {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        //transfer nft back to user
        pool.nonfungiblePositionManager.safeTransferFrom(
            address(this),
            address(msg.sender),
            tokenId
        );
        emit EmergencyWithdraw(msg.sender, tokenId);
        user.liquidity = 0;
        user.rewardDebt = 0;
        StakerFactory(poolInfo.factory).setUserToStaker(
            msg.sender,
            tokenId,
            address(this),
            false
        );
    }

    // Safe sushi transfer function, just in case if rounding error causes pool to not have enough SUSHIs.
    function safeKeroTransfer(address _to, uint256 _amount) internal {
        uint256 keroBal = poolInfo.kero.balanceOf(address(this));
        if (_amount > keroBal) {
            poolInfo.kero.transfer(_to, keroBal);
        } else {
            poolInfo.kero.transfer(_to, _amount);
        }
    }



    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
