// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../lib/forge-std/src/Script.sol";

import {Kerosine}   from "../../contracts/staking/Kerosine.sol";
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

      Kerosine kerosine = new Kerosine();
      Staking  staking  = new Staking(_lpToken, kerosine);

      kerosine.transfer(
        address(staking),
        _stakingRewards
      );

      staking.setRewardsDuration(_rewardsDuration);
      staking.notifyRewardAmount(_stakingRewards);

      kerosine.transfer(
        _owner,                          
        kerosine.totalSupply() - _stakingRewards 
      );

      staking.transferOwnership(_owner);

  }
}
