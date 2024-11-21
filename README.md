# Stable coin 

Stake Document

合约：
一个 stakerFactory 合约，每个epoch对应一个 staker 合约
Stakerfactory提供的功能：
获取现有staker序号数： function epochCreatedIndex() returns(uint256)
获取某个序号的staker地址：function stakers(uint256) returns(address)
用户在哪个staker里质押：function userToStaker(address) returns(address) //若为address(0)则无质押

某个特定Staker提供的功能：
用户在池子里的基本信息：function userInfo(address) returns(uint256 tokenId,uint256 rewardDebt,uint256 liquidity)
用户在池子里的未提取奖励数：function pendingKero(address account) external view returns (uint256)
用户质押NFT： function stake(uint256 tokenId)；//提前授权
用户提取收益： function harvest()
用户提走NFT： function withdraw(uint256 tokenId)
池子总体信息： function poolInfo() returns(
        uint256 lastRewardTime; // Last block number that SUSHIs distribution occurs.
        uint256 accKeroPerShare; // Accumulated SUSHIs per share, times 1e12. See below.
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
        uint256 totalLiquidity;
)
