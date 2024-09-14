// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../dependencies/INonfungiblePositionManager.sol";
import {Staker} from "./Staker.sol";

import "./Kerosene.sol";

contract StakerFactory {

  event StakerCreated(address staker);

  struct StakeDeployedStruct {
        Kerosene kero;
        uint256 keroPerBlock;
        INonfungiblePositionManager nonfungiblePositionManager;
        int24 lowTick;
        int24 upTick;
        uint256 startBlock;
        uint256 endBlock;
        address token0;
        address token1;
        uint24 fee;
        StakerFactory factory;
  }

  address public token0;
  address public token1;
  
  mapping(uint => address) public stakers;
  mapping(address => bool) public isStaker;
  Kerosene public kero;
  INonfungiblePositionManager public nonfungiblePositionManager;



  modifier onlyStaker() {
    require(isStaker[msg.sender], "StakerFactory: caller is not the staker");
    _;
  }
  
  constructor(
    address _kero,
    address _nonfungiblePositionManager,
    address _token0,
    address _token1
  ) {
    kero = Kerosene(_kero);
    nonfungiblePositionManager = INonfungiblePositionManager(_nonfungiblePositionManager);
    token0 = _token0;
    token1 = _token1;
  }


  function createStaker(
      uint24 fee,
      int24 lowTick,
      int24 upTick,
      uint256 startBlock,
      uint256 endBlock,
      uint256 keroPerBlock
  ) external returns (address) {
    Staker staker = new Staker(
       StakeDeployedStruct({
        kero: kero,
        keroPerBlock: keroPerBlock,
        nonfungiblePositionManager: nonfungiblePositionManager,
        lowTick: lowTick,
        upTick: upTick,
        startBlock: startBlock,
        endBlock: endBlock,
        token0: token0,
        token1: token1,
        fee: fee,
        factory: this
      })
    );
    emit StakerCreated(address(staker));
    return address(staker);
  }

  function dropToStaker(uint256 _amount) onlyStaker() external {
    kero.transfer(msg.sender, _amount);
  }

}