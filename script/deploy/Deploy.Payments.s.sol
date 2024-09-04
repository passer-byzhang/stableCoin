// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../lib/forge-std/src/Script.sol";

import {Parameters}   from "../../contracts/params/Parameters.sol";
import {IWETH}        from "../../contracts/interfaces/IWETH.sol";
import {VaultManager} from "../../contracts/core/VaultManager.sol";
import {Payments}     from "../../contracts/periphery/Payments.sol";

contract DeployPayments is Script, Parameters {
  function run() public {
    vm.startBroadcast();  // ----------------------

    Payments payments = new Payments(
      VaultManager(0xfaa785c041181a54c700fD993CDdC61dbBfb420f), 
      IWETH(MAINNET_WETH)
    );

    //
    payments.setFee(MAINNET_FEE);
    payments.setFeeRecipient(MAINNET_FEE_RECIPIENT);
    payments.transferOwnership(MAINNET_OWNER);

    vm.stopBroadcast();  // ----------------------------
  }
}
