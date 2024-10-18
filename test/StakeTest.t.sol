// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./StakerBaseTest.t.sol";

contract StakeTest is StakerBaseTest {
    function testCreateStaker() public {
        address staker = stakerFactory.createStaker(
            fee,
            -60000,
            60000,
            block.timestamp,
            block.timestamp + 100,
            1 ether
        );
        console.log(
            "staker created index: %d",
            stakerFactory.epochCreatedIndex()
        );

        (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        ) = nonfungiblePositionManager.mint(
                INonfungiblePositionManager.MintParams({
                    token0: token0,
                    token1: token1,
                    fee: fee,
                    tickLower: -60000,
                    tickUpper: 60000,
                    amount0Desired: 10,
                    amount1Desired: 10,
                    amount0Min: 0,
                    amount1Min: 0,
                    recipient: address(this),
                    deadline: block.timestamp + 1000000
                })
            );
        console.log("tokenId: %d", tokenId);
        console.log("liquidity: %d", liquidity);
        nonfungiblePositionManager.approve(staker, tokenId);
        Staker(staker).stake(tokenId);
        //skip 100s
        vm.warp(block.timestamp + 100);
        Staker(staker).harvest();
        Staker(staker).withdraw(tokenId);
    }
}
