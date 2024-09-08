// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IDyad}    from "../interfaces/IDyad.sol";
import {Licenser} from "./Licenser.sol";
import {ERC20Upgradeable}    from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract DyadUpgradeable is ERC20Upgradeable, IDyad {
  Licenser public licenser;  

  // dNFT ID => dyad
  mapping (uint => uint) public mintedDyad; 

  function initialize(
    Licenser _licenser
  ) public initializer {
    __ERC20_init("DYAD Stable", "DYAD");
    licenser = _licenser; 
  }


  modifier licensedVaultManager() {
    if (!licenser.isLicensed(msg.sender)) revert NotLicensed();
    _;
  }

  /// @inheritdoc IDyad
  function mint(
      uint    id, 
      address to,
      uint    amount
  ) external 
      licensedVaultManager 
    {
      _mint(to, amount);
      mintedDyad[id] += amount;
  }

  /// @inheritdoc IDyad
  function burn(
      uint    id, 
      address from,
      uint    amount
  ) external 
      licensedVaultManager 
    {
      _burn(from, amount);
      mintedDyad[id] -= amount;
  }
}
