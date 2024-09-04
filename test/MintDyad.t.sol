// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";
import {DNftParameters} from "../contracts/params/DNftParameters.sol";
import {BaseTest} from "./BaseTest.t.sol";
import {IVaultManager} from "../contracts/interfaces/IVaultManager.sol";

contract MintDyadTest is BaseTest {



    function test_DNftDepositAndWithdraw() public {
        uint256 price = DNftParameters(dNft).START_PRICE();
        //uint256 increase = DNftParameters(dNft).PRICE_INCREASE();
        uint dnftId = dNft.mintNft{value: price}(address(this));
        assertEq(dNft.ownerOf(dnftId), address(this)); 
        weth.mint(address(this), 10 ether);
        weth.approve(address(vaultManager), 10 ether);
        vaultManager.add(dnftId, address(wethVault));
        vaultManager.deposit(dnftId, address(wethVault), 10 ether);
        assertEq(wethVault.id2asset(dnftId), 10 ether);
        assertEq(weth.balanceOf(address(this)), 0);
        vm.roll(block.number + 1);
        vaultManager.withdraw(dnftId, address(wethVault), 10 ether,address(this));
        assertEq(wethVault.id2asset(dnftId), 0);
        assertEq(weth.balanceOf(address(this)), 10 ether);
    }

    function test_DyadMintAndBurn() public {
        uint256 price = DNftParameters(dNft).START_PRICE();
        uint dnftId = dNft.mintNft{value: price}(address(this));
        assertEq(dNft.ownerOf(dnftId), address(this)); 
        weth.mint(address(this), 10 ether);
        weth.approve(address(vaultManager), 10 ether);
        vaultManager.add(dnftId, address(wethVault));
        vaultManager.deposit(dnftId, address(wethVault), 10 ether);
        vm.expectRevert(IVaultManager.CrTooLow.selector);
        vaultManager.mintDyad(dnftId, 6667 ether,address(this));
        vaultManager.mintDyad(dnftId, 6666 ether,address(this));
        assertEq(dyad.balanceOf(address(this)), 6666 ether);
        vm.roll(block.number + 1);
        vaultManager.redeemDyad(dnftId,address(wethVault), 6666 ether,address(this));
        assertEq(dyad.balanceOf(address(this)), 0);
        assertEq(weth.balanceOf(address(this)), 6666000000000000000);
        assertEq(weth.balanceOf(address(this)) + wethVault.id2asset(dnftId), 10 ether);

    }
}