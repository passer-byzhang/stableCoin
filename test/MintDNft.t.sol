// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";
import {DNftParameters} from "../contracts/params/DNftParameters.sol";
import {BaseTest} from "./BaseTest.t.sol";

contract MintDNftTest is BaseTest {
    function test_mintDNft() public {
        uint256 price = DNftParameters(dNft).START_PRICE();
        uint256 increase = DNftParameters(dNft).PRICE_INCREASE();
        dNft.mintNft{value: price}(address(this));
        assertEq(dNft.balanceOf(address(this)), 1);
        dNft.mintNft{value: price + increase}(address(this));
        assertEq(dNft.balanceOf(address(this)), 2);
    }

    function testFail_mintDNft() public {
        uint256 price = DNftParameters(dNft).START_PRICE();
        dNft.mintNft{value: price - 1}(address(this));
    }

}