
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract PProxy is TransparentUpgradeableProxy {


    constructor(address _logic, address admin_) TransparentUpgradeableProxy(_logic, admin_, ''){
    }

    function getImplementation() external view returns (address implementation_) {
        return _implementation();
    }

    function updateTo(address _logic) public {
        require(msg.sender==_proxyAdmin(),"only admin can update");
        ERC1967Utils.upgradeToAndCall(_logic, "");
    }

    function getAdmin() public view returns(address){
        return ERC1967Utils.getAdmin();
    }


    receive() external payable {}
}