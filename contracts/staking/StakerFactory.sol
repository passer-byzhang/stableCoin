// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


import {Staker} from "./Staker.sol";

import "./Kerosene.sol";

contract StakerFactory {

  event StakerCreated(address staker);
  

  
  mapping(uint => address) public stakers;
  mapping(address => bool) public isStaker;
  Kerosene public kero;

  modifier onlyStaker() {
    require(isStaker[msg.sender], "StakerFactory: caller is not the staker");
    _;
  }


  function createStaker(
      address _token,
      address _oracle,
      address _vault,
      uint256 _minStake,
      uint256 _maxStake,
      uint256 _fee
  ) external returns (address) {
    Staker staker = new Staker(_token, _oracle, _vault, _minStake, _maxStake, _fee);
    emit StakerCreated(address(staker));
    return address(staker);
  }

  function dropToStaker(uint256 _amount) onlyStaker() external {
    kero.transfer(msg.sender, _amount);
  }








}