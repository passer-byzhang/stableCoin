// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";

import "../contracts/mock/ERC20Mock.sol";
import {Staker} from "../contracts/staking/Staker.sol";
import {StakerFactory} from "../contracts/staking/StakerFactory.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../contracts/staking/StakerFactory.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

import "../contracts/dependencies/INonfungiblePositionManager.sol";


contract StakerBaseTest is Test {

    address public token0;
    address public token1;
    uint24 public fee = 3000;

    address public kero;

    IUniswapV3Factory public uniswapFactory;
    address public uniswapPoolAddress_Base = 0x33128a8fC17869897dcE68Ed026d694621f6FDfD;
    IUniswapV3Pool public uniswapPool;
    address public nonfungiblePositionManagerAddress_Base = 0x03a520b32C04BF3bEEf7BEb72E919cf822Ed34f1;
    INonfungiblePositionManager public nonfungiblePositionManager;
    StakerFactory public stakerFactory;

    function setUp() public {
        //vm.createFork("https://mainnet.base.org");
        address tokenA = address(new ERC20Mock("TOKENA", "A"));
        console.log("tokenA: %s", tokenA);
        address tokenB = address(new ERC20Mock("TOKENB", "B"));
        console.log("tokenB: %s", tokenB);
        kero = address(new ERC20Mock("Kero","K"));
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        uniswapFactory = IUniswapV3Factory(address(uniswapPoolAddress_Base));
        nonfungiblePositionManager = INonfungiblePositionManager(address(nonfungiblePositionManagerAddress_Base));
        console.log("owner: %s", uniswapFactory.owner());
        address uniswapPoolAddress = uniswapFactory.createPool(token0, token1, 3000);
        console.log("uniswapPoolAddress: %s", uniswapPoolAddress);
        uniswapPool = IUniswapV3Pool(uniswapPoolAddress);
        uniswapPool.initialize(uint160(1) << 96);
        console.log("uniswapPool inited");
        console.log("tickSpacing: %d", uniswapPool.tickSpacing());
        ERC20Mock(payable(token0)).mint(address(this), 100 ether);
        ERC20Mock(payable(token1)).mint(address(this), 100 ether);
        ERC20Mock(payable(kero)).mint(address(this), 1000000 ether);
        ERC20Mock(payable(token0)).approve(nonfungiblePositionManagerAddress_Base, 100 ether);
        ERC20Mock(payable(token1)).approve(nonfungiblePositionManagerAddress_Base, 100 ether);
         stakerFactory = new StakerFactory(
            kero,
            address(nonfungiblePositionManager),
            token0,
            token1,
            address(this)
        );
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable {}
}