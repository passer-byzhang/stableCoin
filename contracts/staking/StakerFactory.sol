// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../dependencies/INonfungiblePositionManager.sol";
import {Staker} from "./Staker.sol";
import {Owned} from "solmate/src/auth/Owned.sol";

import "./Kerosene.sol";

contract StakerFactory is Owned {
    event StakerCreated(uint index,address staker);

    struct StakeDeployedStruct {
        Kerosene kero;
        uint256 keroPerTime;
        INonfungiblePositionManager nonfungiblePositionManager;
        int24 lowTick;
        int24 upTick;
        uint256 startTime;
        uint256 endTime;
        address token0;
        address token1;
        uint24 fee;
        StakerFactory factory;
    }

    address public token0;
    address public token1;



    mapping(uint => address) public stakers;
    mapping(address => bool) public isStaker;
    mapping(address => address) public userToStaker;
    Kerosene public kero;
    uint256 public epochCreatedIndex;

    INonfungiblePositionManager public nonfungiblePositionManager;

    modifier onlyStaker() {
        require(
            isStaker[msg.sender],
            "StakerFactory: caller is not the staker"
        );
        _;
    }

    constructor(
        address _kero,
        address _nonfungiblePositionManager,
        address _token0,
        address _token1,
        address _owner
    ) Owned(_owner) {
        kero = Kerosene(_kero);
        nonfungiblePositionManager = INonfungiblePositionManager(
            _nonfungiblePositionManager
        );
        (token0, token1) = _token0 < _token1
            ? (_token0, _token1)
            : (_token1, _token0);
    }

    function createStaker(
        uint24 fee,
        int24 lowTick,
        int24 upTick,
        uint256 startTime,
        uint256 endTime,
        uint256 keroPerTime
    ) external onlyOwner returns (address) {
        require(startTime<endTime, "StakerFactory: startTime should be less than endTime");
        require(lowTick<upTick, "StakerFactory: lowTick should be less than upTick");
        StakeDeployedStruct memory newStaker = StakeDeployedStruct({
            kero: kero,
            keroPerTime: keroPerTime,
            nonfungiblePositionManager: nonfungiblePositionManager,
            lowTick: lowTick,
            upTick: upTick,
            startTime: startTime,
            endTime: endTime,
            token0: token0,
            token1: token1,
            fee: fee,
            factory: this
        });

        if (epochCreatedIndex > 0) {
            (, , , , , , , , uint256 lastendTime, , , , , ) = Staker(
                stakers[epochCreatedIndex]
            ).poolInfo();
            require(
                startTime > lastendTime,
                "StakerFactory: epoch not finished"
            );
        }
        Staker staker = new Staker(newStaker);

        epochCreatedIndex++;
        stakers[epochCreatedIndex] = address(staker);
        isStaker[address(staker)] = true;
        emit StakerCreated(epochCreatedIndex,address(staker));
        return address(staker);
    }

    function setUserToStaker(address _user,uint _tokenId,address _staker,bool isStaked) public onlyStaker {
        if(isStaked){
            userToStaker[_user] = _staker;
        }else{
            userToStaker[_user] = address(0);
        }
    }

    function dropToStaker(uint256 _amount) external onlyStaker {
        kero.transfer(msg.sender, _amount);
    }
}
