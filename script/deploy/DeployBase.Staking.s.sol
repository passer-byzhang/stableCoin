// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../lib/forge-std/src/Script.sol";

import {Kerosene}   from "../../contracts/staking/Kerosene.sol";
import {Staking}    from "../../contracts/staking/Staking.sol";
import {Parameters} from "../../contracts/params/Parameters.sol";

import {ERC20} from "solmate/src/tokens/ERC20.sol";

contract StakingDeployBase is Script {
  function deploy(
      address _owner, 
      uint    _stakingRewards,
      uint    _rewardsDuration,
      ERC20   _lpToken
  ) public {

      Kerosene kerosene = new Kerosene();
      Staking  staking  = new Staking(_lpToken, kerosene);

      kerosene.transfer(
        address(staking),
        _stakingRewards
      );

      staking.setRewardsDuration(_rewardsDuration);
      staking.notifyRewardAmount(_stakingRewards);

      kerosene.transfer(
        _owner,                          
        kerosene.totalSupply() - _stakingRewards 
      );

      staking.transferOwnership(_owner);

  }
}
