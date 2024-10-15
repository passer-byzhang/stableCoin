// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../lib/forge-std/src/Script.sol";
import {DNft}          from "../../contracts/core/DNft.sol";
import {Dyad}          from "../../contracts/core/Dyad.sol";
import {VaultLicenser}      from "../../contracts/core/VaultLicenser.sol";
import {Licenser}      from "../../contracts/core/Licenser.sol";
import {VaultManager}  from "../../contracts/core/VaultManager.sol";
import {Vault}         from "../../contracts/core/Vault.sol";
import {Kerosene}   from "../../contracts/staking/Kerosene.sol";
import {Payments}      from "../../contracts/periphery/Payments.sol";
import {IAggregatorV3} from "../../contracts/interfaces/IAggregatorV3.sol";
import {IWETH}         from "../../contracts/interfaces/IWETH.sol";
import {DyadXP}        from "../../contracts/staking/DyadXP.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";

// only used for stack too deep issues
struct Contracts {
  Licenser     vaultManagerLicenser;
  VaultLicenser     vaultLicenser;
  Dyad         dyad;
  VaultManager vaultManager;
  Vault        vault;
  Payments     payments;
  Kerosene     kerosene;
}

contract DeployBase is Script {

  function deploy(
    address _owner, 
    address _dNft,
    address _asset,
    address _oracle, 
    uint    _fee,
    address _feeRecipient
  )
    public 
    payable 
    returns (
      Contracts memory
    ) {
      DNft dNft = DNft(_dNft);

      vm.startBroadcast();  // ----------------------

      Licenser vaultManagerLicenser = new Licenser();
      VaultLicenser vaultLicenser        = new VaultLicenser();

      Dyad dyad                     = new Dyad(
        vaultManagerLicenser
      );

      Kerosene kerosene             = new Kerosene();

      VaultManager vaultManager     = new VaultManager();

      Vault vault                   = new Vault(
        vaultManager,
        ERC20(_asset),
        IAggregatorV3(_oracle)
      );

      Payments payments             = new Payments(
        vaultManager,
        IWETH(_asset)
      );

      //
      payments.setFee(_fee);
      payments.setFeeRecipient(_feeRecipient);

      // 
      vaultManagerLicenser.add(address(vaultManager));
      vaultLicenser       .add(address(vault),false);

      //
      vaultManagerLicenser.transferOwnership(_owner);
      vaultLicenser       .transferOwnership(_owner);
      payments            .transferOwnership(_owner);


      vm.stopBroadcast();  // ----------------------------

      return Contracts(
        vaultManagerLicenser,
        vaultLicenser,
        dyad,
        vaultManager,
        vault, 
        payments,
        kerosene
      );
  }
}
