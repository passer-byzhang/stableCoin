// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";

import "../contracts/mock/ERC20Mock.sol";
import "../contracts/staking/Staker.sol";
import "../contracts/staking/StakerFactory.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

import "../contracts/dependencies/INonfungiblePositionManager.sol";


contract StakerBase is Test {



    address public token0;
    address public token1;

    IUniswapV3Factory public uniswapFactory;
    address public uniswapPoolAddress_Base = 0x33128a8fC17869897dcE68Ed026d694621f6FDfD;
    IUniswapV3Pool public uniswapPool;

    StakerFactory public stakerFactory;

    function setUp() public {
        address tokenA = address(new ERC20Mock("TOKENA", "A"));
        address tokenB = address(new ERC20Mock("TOKENB", "B"));
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        uniswapFactory = IUniswapV3Factory(address(uniswapPoolAddress_Base));
        address uniswapPoolAddress = uniswapFactory.createPool(token0, token1, 3000);
        uniswapPool = IUniswapV3Pool(uniswapPoolAddress);
    }


}