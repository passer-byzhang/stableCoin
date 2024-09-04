// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Owned} from "solmate/src/auth/Owned.sol";
import {Parameters} from "../params/Parameters.sol";
import {Kerosene} from "../staking/Kerosene.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract KeroseneDenominatorV2 is Owned {
  using EnumerableSet for EnumerableSet.AddressSet;

  Kerosene public kerosene;

  EnumerableSet.AddressSet private _excludedAddresses;

  constructor(
    Kerosene _kerosene
  ) Owned(0xDeD796De6a14E255487191963dEe436c45995813){
    kerosene = _kerosene;
    _excludedAddresses.add(0xDeD796De6a14E255487191963dEe436c45995813); // Team Multisig
    _excludedAddresses.add(0x3962f6585946823440d274aD7C719B02b49DE51E); // Sablier Linear Lockup
  }

  function setAddressExcluded(address _address, bool exclude) external onlyOwner {
    if (exclude) {
      _excludedAddresses.add(_address);
    } else {
      _excludedAddresses.remove(_address);
    }
  }

  function isExcludedAddress(address _address) external view returns (bool) {
    return _excludedAddresses.contains(_address);
  }

  function excludedAddresses() external view returns (address[] memory) {
    return _excludedAddresses.values();
  }

  function denominator() external view returns (uint) {
    uint computedDenominator = kerosene.totalSupply();
    uint excludedAddressLength = _excludedAddresses.length();
    for (uint i = 0; i < excludedAddressLength; ++i) {
      computedDenominator -= kerosene.balanceOf(_excludedAddresses.at(i));
    }
    return computedDenominator;
  } 
}
