# Stable coin

Tab1 EarnKerosene

1. 每个人的 nftIds (DNft合约)
    1.1 获取用户的balance: balanceOf(address owner) return (uint256) 返回值记为n
    1.2 从0到n-1 检索 tokenOfOwnerByIndex(address owner, uint256 index) returns (uint256) 返回对应的 nftId
2. 获取某个nft 的 Collateralization ratio (VaultManager合约)
    collatRatio(uint id) returns (uint) 返回值有18位精度
3. DYAD minted (Dyad合约)
    mintedDyad(uint id) returns (uint),参数id为nftid
4. Collateral 和 Exogenous Collateral (VaultManager合约)
   getVaultsValues(uint id) returns (uint exoValue, uint keroValue) 返回值 Collateral = exoValue + keroValue, Exogenous Collateral = exoValue
5. 某个nft的所有已添加vault
   vaults(uint id) retuens (address[]) 
6. 某个token的质押量 Token deposited (Vault合约)
   id2asset(uint id) returns (uint), 参数id为nftid
7. 某个token质押的价值 Total value (USD)
   getUsdValue(uint id) returns (uint), 参数id为nftid
8. mint最大值(VaultManager合约)
    (uint exoValue, uint keroValue) = getVaultsValues(id);
    设目前想mint的数据是x, 已mint的数目为 mintedDyad
    第一个限制是: x+mintedDyad<=exoValue
                x<=exoValue-mintedDyad
    第二个限制为：(exoValue+keroValue)*1e18/(mintedDyad+x) >= MIN_COLLAT_RATIO(此值为1.5e18)
                x<=(exoValue+keroValue)*1e18/(1.5e18)-mintedDyad
    则得到 max = Min(exoValue-mintedDyad,(exoValue+keroValue)*1e18/(1.5e18)-mintedDyad)

   