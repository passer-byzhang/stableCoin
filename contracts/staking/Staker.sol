// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Kerosene.sol";
import "./StakerFactory.sol";

//for uniswap v3
import "../dependencies/INonfungiblePositionManager.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IERC20Minimal.sol";

contract Staker  {
    using Math for uint256;
    //using SafeERC20 for IERC20;
    // Info of each user.
    struct UserInfo {
        uint256 tokenId; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
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
        uint256 allocPoint; // How many allocation points assigned to this pool. SUSHIs to distribute per block.
        uint256 lastRewardBlock; // Last block number that SUSHIs distribution occurs.
        uint256 accKeroPerShare; // Accumulated SUSHIs per share, times 1e12. See below.
        // The REWARD TOKEN!
        Kerosene kero;
        // Block number when bonus SUSHI period ends.
        uint256 bonusEndBlock;
        // SUSHI tokens created per block.
        uint256 keroPerBlock;
        //for uniswap v3
        INonfungiblePositionManager nonfungiblePositionManager;
        int24 lowTick;
        int24 upTick;
        // The block number when SUSHI mining starts.
        uint256 startBlock;
        address token0;
        address token1;
        uint24 fee;
        StakerFactory factory;
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
    event EmergencyWithdraw(address indexed user, uint256 tokenId);

    constructor(PoolInfo memory _poolInfo) public {
        poolInfo = _poolInfo;
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
        _;
    }

    // View function to see pending SUSHIs on frontend.
    function pendingKero(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 accSushiPerShare = poolInfo.accKeroPerShare;
        uint256 lpSupply = poolInfo.lpToken.balanceOf(address(this));
        if (block.number > poolInfo.lastRewardBlock && lpSupply != 0) {
            uint256 keroReward = poolInfo.keroPerBlock
                .mul(poolInfo.allocPoint)
                .div(poolInfo.totalAllocPoint);
            poolInfo.accKeroPerShare = accSushiPerShare.add(
                keroReward.mul(1e12).div(lpSupply)
            );
        }
        return
            user.amount.mul(poolInfo.accKeroPerShare).div(1e12).sub(
                user.rewardDebt
            );
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool() public {
        if (block.number <= poolInfo.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = poolInfo.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            poolInfo.lastRewardBlock = block.number;
            return;
        }
        uint256 keroReward = poolInfo.sushiPerBlock
            .mul(poolInfo.allocPoint)
            .div(poolInfo.totalAllocPoint);
        poolInfo.factory.drop(keroReward);
        poolInfo.accSushiPerShare = poolInfo.accSushiPerShare.add(
            keroReward.mul(1e12).div(lpSupply)
        );
        poolInfo.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for SUSHI allocation.
    function stake(uint256 tokenId) public nftEligibe(tokenId) {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        (
            ,
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
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(poolInfo.accSushiPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            safeKeroTransfer(msg.sender, pending);
        }
        poolInfo.nonfungiblePositionManager.safeTransferFrom(
            address(msg.sender),
            address(this),
            tokenId
        );
        user.amount = user.amount.add(liquidity);
        user.rewardDebt = user.amount.mul(poolInfo.accSushiPerShare).div(1e12);
        emit Deposit(msg.sender, tokenId, liquidity);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 tokenId) public {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        uint256 pending = user
            .amount
            .mul(poolInfo.accSushiPerShare)
            .div(1e12)
            .sub(user.rewardDebt);
        safeKeroTransfer(msg.sender, pending);
        user.amount = 0;
        user.rewardDebt = user.amount.mul(poolInfo.accKeroPerShare).div(1e12);
        poolInfo.nonfungiblePositionManager.safeTransferFrom(address(this),address(msg.sender), tokenId);
        emit Withdraw(msg.sender, tokenId);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 tokenId) public {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, tokenId);
        user.amount = 0;
        user.rewardDebt = 0;
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
