// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";
import {DeployBase, Contracts} from "../script/deploy/DeployBase.s.sol";
import {Parameters} from "../contracts/params/Parameters.sol";
import {DNft} from "../contracts/core/DNft.sol";
import {Dyad} from "../contracts/core/Dyad.sol";
import {VaultLicenser} from "../contracts/core/VaultLicenser.sol";
import {Licenser} from "../contracts/core/Licenser.sol";
import {VaultManager} from "../contracts/core/VaultManager.sol";
import {Vault} from "../contracts/core/Vault.sol";
import {Payments} from "../contracts/periphery/Payments.sol";
import {OracleMock} from "./mock/OracleMock.sol";
import {ERC20Mock} from "./mock/ERC20Mock.sol";
import {IAggregatorV3} from "../contracts/interfaces/IAggregatorV3.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {Kerosene}   from "../contracts/staking/Kerosene.sol";
import {DyadXP}   from "../contracts/staking/DyadXP.sol";

contract BaseTest is Test, Parameters {
  DNft         dNft;
  Licenser     vaultManagerLicenser;
  VaultLicenser     vaultLicenser;
  Dyad         dyad;
  VaultManager vaultManager;
  Payments     payments;
  Kerosene     kerosene;

  // weth
  Vault        wethVault;
  ERC20Mock    weth;
  OracleMock   wethOracle;

  // dai
  Vault        daiVault;
  ERC20Mock    dai;
  OracleMock   daiOracle;

  // kerosene
  Vault        keroseneVault;
  OracleMock   keroseneOracle;


  DyadXP       dyadXp;

  function setUp() public {
    dNft       = new DNft();
    weth       = new ERC20Mock("WETH-TEST", "WETHT");
    wethOracle = new OracleMock(1000e8);

    Contracts memory contracts = new DeployBase().deploy(
      msg.sender,
      address(dNft),
      address(weth),
      address(wethOracle), 
      GOERLI_FEE,
      GOERLI_FEE_RECIPIENT
    );

    vaultManagerLicenser = contracts.vaultManagerLicenser;
    vaultLicenser        = contracts.vaultLicenser;
    dyad                 = contracts.dyad;
    vaultManager         = contracts.vaultManager;
    wethVault            = contracts.vault;
    payments             = contracts.payments;
    kerosene             = contracts.kerosene;

    // create the DAI vault
    dai       = new ERC20Mock("DAI-TEST", "DAIT");
    daiOracle = new OracleMock(1e6);
    daiVault  = new Vault(
      vaultManager,
      ERC20(address(dai)),
      IAggregatorV3(address(daiOracle))
    );

    keroseneOracle = new OracleMock(5);
    keroseneVault  = new Vault(
      vaultManager,
      ERC20(address(dai)),
      IAggregatorV3(address(daiOracle))
    );

    dyadXp = new DyadXP(address(vaultManager),  address(keroseneVault),  address(dNft));

    //init vaultmanager
    vaultManager.initialize(address(dyadXp),dNft,dyad,vaultLicenser);
    vaultManager.setKeroseneVault(address(keroseneVault));
    // add the DAI vault
    vm.startBroadcast(vaultLicenser.owner());
    vaultLicenser.add(address(daiVault),false);
    vaultLicenser.add(address(keroseneVault),true);    
    vaultLicenser.add(address(wethVault),false);
    vm.stopBroadcast();
  }

  receive() external payable {}

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure returns (bytes4) {
    return 0x150b7a02;
  }
}

