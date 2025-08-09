# Yusan Investment Thesis

## 1. Executive Summary

**Yusan is a multi-chain money market with a CEX-like experience**

* **First Mover**: Yusan will be the first lending protocol on ICP ($3B market cap)
* **Cross-Chain Engine**: Borrow/lend assets from any chain to any other without complexity
* **Innovative Design**: Higher yield than pool-based lending through novel liquidations
* **Proven Team**: Ex-DFINITY engineers and core contributors to #1 ICP DeFi protocol
* **Ask**: $2M-$5M raise

## 2. Moat: Native Cross-Chain Architecture

Yusan's moat lets you open shorts or longs on BTC directly from BTC mainnet. You just need to send your BTC to your own BTC address, deposit in the pool, and click to loop for a long. No need for bridges, wrapped assets, or risking MEV sniping.

Yusan leverages chain-key cryptography for secure cross-chain orchestration. Through signing transactions and sending them around, we achieve:

- One unified pool instead of multiple fragmented ones across many chains.
- CEX experience: Dedicated address per chain (ETH, Bitcoin, ICP)

Powered by our team's bridging smart contracts leveraging:

- Threshold ECDSA: Sign BTC/EVM transactions in a decentralized fashion, no single node has the key
- Bitcoin light node: Every ICP node runs a Bitcoin light node, direct BTC data no intermediaries
- HTTP outcalls: Reach RPC through consensus

Compared to perps, Yusan offers lower fees, easier UX, and built-in yield for your BTC from people going long or short. We can assume more risk than traditional lending thanks to our unique liquidation strategy.

## 3 Protocol Design

### 3.1 Pool-based Lending

Yusan is built on a pool-based lending system, the same as those that power top money markets like Compound or AAVE.

* **Lending/Borrowing**: In pool-based lending, users supply one or multiple assets to earn yield. Once deposited, those assets can also act as collateral to borrow from other pools. Interest rates on a user's loans are set by pool utilization—the fewer assets in the borrow pool, the higher the interest users pay. As rates increase, demand drops, diminishing rates and incentivizing new borrowing, creating a balanced system. Below is a visual representation of interest rates against pool utilization.

<iframe width="900" height="300" seamless frameborder="0" scrolling="no" src="https://dune.com/embeds/3282730/5495202"/> </iframe>

* **Core Risk Management**: Yusan sets risk parameters on each asset. The health factor $H_f$ shown below computes the safety of all a user's deposited assets. A health factor above 1 is a healthy position; below 1, some positions become eligible for liquidations. This is an essential step to prevent bad debt and ensure the protocol remains solvent.

$$H_f = \frac{\sum\ (Collateral_i\ in\ USD \cdot Liquidation\ Threshold_i)}{Total\ Borrows\ in\ USD}$$

### 3.2 Yusan Liquidation Pools: A Generalized, MEV-Resistant Liquidation Engine

As mentioned previously, once the $H_f$ of a user drops below 1, their position needs to be liquidated to maintain protocol solvency. To incentivize repayment of the debt, protocols typically offer a 5-10% discount on the collateral.

The battle to get this discount is usually won by sophisticated players, MEV (Maximal Extractable Value) bots, which race to be the first to liquidate users and claim the liquidation bonus. Liquidation volume represents, with an average fee of 5% on AAVE v3, this means $3,600,000,000 USD \cdot 5\% = $180,000,000 going to the MEV bots instead of the users of the protocol.

<iframe width="900" height="350" seamless frameborder="0" scrolling="no" src="https://dune.com/embeds/1955184/3227781?Time+interval_e15077=month&Trading+Num+Days_n26d66=360"/></iframe>

#### Current Flawed Solutions

Leading protocols have already tried to fix this known problem:

* **AAVE with SVR**

 AAVE uses Chainlink's SVR (Smart Value Recapture) to "recapture" liquidation bonuses. The approach currently recaptures between 25-75% of the liquidations, which is highly inefficient.

 ![image](https://raw.githubusercontent.com/EnzoPlayer0ne/yusan-thesis/refs/heads/master/images/svr-recapture.png)

Even when it recaptures the underlying liquidations, AAVE only benefits from a small amount of the liquidation bonus, and AAVE users see none of this.

![image](https://raw.githubusercontent.com/EnzoPlayer0ne/yusan-thesis/refs/heads/master/images/liquidation-bonus-split.png)

* **Liquity Stability Pool**: Liquity liquidations are simple; a stability pool liquidates a user by repaying their debt and distributing the collateral and its bonus pro-rata to the pool. This prevents a single MEV bot from sniping all the rewards.

However, it comes with its own flaws:

1. Liquity is a CDP and not a money market, so it only works between their stablecoin and the three collaterals they allow
2. Relies on external parties that get compensated to call the permissionless liquidations functions.

![image](https://cdn.prod.website-files.com/5fe512bf3e57baa22a4812f0/66d5a18b7f0cf323863d6a3a_662f9955cdd0eb407540a7e2_uB4JF5-p52n7KIrO6YrMu35qitRK5tqP42Hx9R0jo0ajNA13zGc4AXIXxXKWqTmH04Aa1X2am2i0Vhsi5wiHqYWSDqCek17ZEFQx_3FJWfOAkmCyL_SV6zuwaUO-_TttXMlLMnTg5XBpW7xGl97loRY.avif)

#### Yusan Solution: Generalized and Automated Liquidations Engine

Yusan takes the strong points of both models while fixing their flaws, thus creating the first truly efficient liquidation engine for money markets.

First, **we generalized Liquity's Stability pool into our own called Liquidation Pool**. Meaning, when a user gets liquidated, the liquidation pool provides the capital to repay the debt. The collateral and the liquidation bonus are then distributed pro-rata to the pool. All of the value is fully captured and goes right back to the protocol.

Second, **no need for external parties**, the liquidation events are automatically processed once a position reaches LTV. No more missing out by leveraging ICP's timers—Yusan initiates the liquidations by itself. Added bonus: A single individual cannot liquidate large positions, but the pool can.

Liquidation pools offer two distinct advantages:

1. **100% capture**: All the liquidation bonuses are redistributed to the pool, and not to MEV or partially to the protocol like in SVR's case. It unlocks a new wave of yield, which we will see in the next section.
2. **Enhanced security**: The protocol at any point knows how much price drops it can handle; we don't rely on off-chain capital willing to liquidate users' positions when the market swings.

**Added bonus**: The liquidation pools allow users to set intents. You can stack yield with whatever you wish. Deposit USDC, stack in BTC.

When the pool liquidates a user, it ends up with an asset different from the one the user supplied. Some users will not want this new exposure and can choose to swap the new collateral they have received for another asset.

For instance, let's say you deposit USDC, which is partly used to liquidate someone borrowing against BTC—you will end up with BTC. You can now choose whether to:

- Keep the BTC
- Swap the BTC for what you had earlier
- Swap the BTC for any other asset; you can choose to stack ICP

## 4. Growth Flywheels

Our growth strategy is to deliver yield on products with no prior yield in iterative steps, building one on top of the other, creating liquidity and meeting users' needs at every step of the way. We start with USDC yield to attract stablecoin TVL, before going after ICP yield with no lock-up, and finally expanding to the BTC market. All of those yields boosted by our innovation **smart-yield**, which splits your collateral between both lending and liquidation pools for maximized yield.

### 4.1 USDC Yield

As we have seen before, in leading protocols like AAVE, stablecoins represent half of the borrows and a third of the deposits. The demand for stablecoins comes from borrowers seeking liquidity against their volatile assets. This demand is currently not being met on ICP.

On Ethereum, against the base asset of the chain (WETH), we can see 90% of the borrows putting WETH as collateral are for stablecoins from the [WETH Chaos Labs Dashboard](https://community.chaoslabs.xyz/aave/risk/markets/Ethereum-main/listed-assets/WETH).

![image](https://raw.githubusercontent.com/EnzoPlayer0ne/yusan-thesis/refs/heads/master/images/WETH-borrow-against.png)

The same can be seen for yield-bearing assets like wstETH, where stablecoins account for 40% of the borrows, from the [wstETH Chaos Labs Dashboard](https://community.chaoslabs.xyz/aave/risk/markets/Ethereum-main/listed-assets/wstETH):

![image](https://raw.githubusercontent.com/EnzoPlayer0ne/yusan-thesis/refs/heads/master/images/wstETH-borrow-against.png)

Meeting this demand would push USDC/USDT yield to around 5%. As it is currently unmet while ICP has grown to ~$27M DeFi TVL. The chain currently lacks a money market, leaving users with no solutions for sustainable and safe stablecoin yield.

The next pressure is the demand for going long on ICP by people taking leverage. Part of the yield would be from users seeking liquidity, the other part from users looping for leverage. You will be able to achieve a 5x ICP exposure by depositing ICP, borrowing USDC, buying more ICP, and so on.

![image](https://raw.githubusercontent.com/EnzoPlayer0ne/yusan-thesis/refs/heads/master/images/leverage-icp.png)

You can take even larger leverage by using nICP as collateral. Given nICP yield is around 14%, if ICP goes sideways, the yield of nICP would pay off the debt it accrues.

### 4.3 BTC Leverage

With the deep partnership with OneSec (same team), we can offer a BTC-focused product once we have enough stablecoin TVL, allowing people from BTC to loop and take longs on their BTC. 

Looping also works on BTC the same way we described it above. This time, tapping on the USDC cross-chain pool is an advantage. It lets people deposit on BTC and loop from there. You can see it's already the case below on other protocols, people borrow USDC to get liquidity on the asset or to take a long. 

![image](https://raw.githubusercontent.com/EnzoPlayer0ne/yusan-thesis/refs/heads/master/images/WBTC-borrow-against.png)

On top of this users get their own BTC address, to which they can deposit BTC and then use on the platform. Facilitating with a BTC address lets us address a deeper market.

### 4.4 Smart-Yield

Next, Yusan smart-yield will balance your collateral between the liquidation pool and the lending pool. The liquidation pool should have good APY per below:

<iframe width="900" height="350" seamless frameborder="0" scrolling="no" src="https://dune.com/embeds/5596737/9105012"/> </iframe>

Most liquidations are stablecoins:

<iframe width="900" height="350" seamless frameborder="0" scrolling="no" src="https://dune.com/embeds/4692692/7804620?Trading+Num+Days_n26d66=360"/> </iframe>

But they liquidate WETH (reinforcing the demand to be liquid on the main asset of the network):

<iframe width="900" height="350" seamless frameborder="0" scrolling="no" src="https://dune.com/embeds/4692685/7804615?Trading+Num+Days_n26d66=360"/></iframe>

This mechanism allows us to take more risks on the platform as liquidations are done automatically and we tap into the full TVL rather than relying on off-chain MEV.

## 5. $YUSAN

### Tokenomics

The $YUSAN token will fully control the platform, from smart contracts to frontend. All risk settings, asset listings, and protocol upgrades are voted on by the DAO and automatically rolled out once decisions reach 50%.

#### Fees

The DAO takes a 10% flat fee on loan payments and liquidations. The fees are kept in reserves to be used in case of bad debt in the protocol.

#### Parameters

- **21 days lock time**, flat non-variable lock time, long enough to see people unstake and foresee voting power change
- **staked tokens non-transferable**, prevents quick governance attack
- **1.5% annual inflation**
- **100% 6-month age bonus**, locking and holding for 6 months yields you 3% instead of 1.5%
- **90% locked and 10% liquid at launch**, no vesting

#### Voting Power

Every pre-launch holder tagged in a dashboard similar to [WaterNeuron voting power dashboard](https://dashboard.waterneuron.fi/):

![image](https://raw.githubusercontent.com/EnzoPlayer0ne/yusan-thesis/refs/heads/master/images/waterneuron-vp.png)

### Ask

- $2-$5M seed, previous round $500k @ $5M

**Use of Funds**

- 30% engineering, smart contract devs and audits
- 30% growth, marketing community building, incentives, the IC has great tech but has not been put under a lot of eyeballs
- 10% operations, legal compliance, infrastructure
- 30% safety fund, bad debt insurance

## 6. Team & Traction

The team is made up of ex-DFINITY engineers and early contributors to waterneuron.fi and onesec.to.

WaterNeuron in figures:

- **TVL** $2.5M ICP, organic no liquidity deals
- **Marketcap** $20M (MCAP/TVL ~1.4)
- **Annual Holders Revenue**: $140k, 60th in DeFi
- **DAO**: [#1 DAO by number of proposals in crypto](https://defillama.com/governance)
- **Use of Funds**: All the 1M ICP raised stayed on-chain, staked for the maximum amount of time and the yield distributed for sustainable incentives. The staked ICP is controlled by the DAO.
- **Active community**: WaterNeuron Telegram chat has become one of the hubs for all DeFi related questions and user education on ICP
- **DFINITY Investment**: of [350k ICP in the latest round](https://forum.dfinity.org/t/waterneuron-dao-watermelon-swap-with-the-dfinity-foundation/50794)
- **ICP DeFi**: 2/3rd of all ICP in DeFi are with WaterNeuron

<iframe width="600" height="380" seamless frameborder="0" scrolling="no" src="https://docs.google.com/spreadsheets/d/e/2PACX-1vS28rYw2_FJkyxwT4hL__hq1D7-al8nThy_SqeEDDaGvob42KygNcwD5f3ejS9HFnGQNNAgFlvtN-ra/pubchart?oid=46921035&amp;format=interactive"></iframe>

* **Liquidity**: nICP has the deepest liquidity out of any token on ICP

<iframe width="602" height="380" seamless frameborder="0" scrolling="no" src="https://docs.google.com/spreadsheets/d/e/2PACX-1vS28rYw2_FJkyxwT4hL__hq1D7-al8nThy_SqeEDDaGvob42KygNcwD5f3ejS9HFnGQNNAgFlvtN-ra/pubchart?oid=1299217898&amp;format=interactive"></iframe>

<iframe width="900" height="556" seamless frameborder="0" scrolling="no" src="https://defillama.com/protocol/waterneuron?denomination=ICP"></iframe>

## 7. Market Opportunity

Every successful DeFi ecosystem is built on top of a few primitives: a liquid staking, a stablecoin, a decentralized exchange (DEX), and a money market. When combined, these primitives create a flywheel of liquidity and growth. Miss one piece of the puzzle and the on-chain economy is stifled and cannot reach its full potential.

Until now, ICP has been missing the money-market piece. In the last year there has been the launch of a solid liquid staking and bridged stablecoin. We are now only missing a money market to unlock the full potential of DeFi on the IC. Yusan is that money market.

![image](https://raw.githubusercontent.com/EnzoPlayer0ne/yusan-thesis/refs/heads/master/images/wheel.png)

### Quantifying the TAM

On every other chain that has all those primitives, lending is ~25% of the chain's TVL:

<iframe width="600" height="380" seamless frameborder="0" scrolling="no" src="https://docs.google.com/spreadsheets/d/e/2PACX-1vQpjcaAiuZav0Ah2mKW6Vz5gpQWawVAmOVtpu4T46FTSTm5a713lvsRc3uKiG5vUgyuVcW6e0icE4j8/pubchart?oid=1783534872&amp;format=interactive"></iframe>

Currently the TVL of ICP is $32M, introducing a lending protocol could grow the ecosystem's total value:

$$\frac{potential\ lending\ tvl}{$32M+ potential\ lending\ tvl}=25\%$$

Solving this gives us **$11M in new TVL**. Most of the deposits would come from a few classes of assets. If we compare with the industry leader on Ethereum, AAVE's deposits are as follows:

<iframe width="900" height="350" seamless frameborder="0" scrolling="no" src="https://dune.com/embeds/3214653/5374461"></iframe>

Grouped per category:

<iframe width="900" height="350" seamless frameborder="0" scrolling="no" src="https://dune.com/embeds/5590469/9096229"></iframe>

Which gives us roughly:

- 1/3rd is stablecoins
- 1/3rd is liquid staking derivatives
- 1/3rd is base tokens (WETH) and BTC

Now if we look at what people borrow:

<iframe width="900" height="350" seamless frameborder="0" src="https://dune.com/embeds/3214653/5374465"></iframe>

Now if we break this down again, stablecoins represent half of the borrowed amount, and WETH more than a third.

<iframe width="900" height="350" seamless frameborder="0" src="https://dune.com/embeds/5590798/9096351"></iframe>

It's roughly 50% stablecoins and 40% WETH. The high amount of WETH might be surprising; however, it points to sophisticated users looping liquid staking derivatives (LSDs) to maximize their yield exposure. The stablecoin borrows are either to maximize leverage or simply going long while being liquid.

### Sources

- https://svr.llamarisk.com/
- https://dune.com/KARTOD/AAVE-Mega-Dashboard
- https://dune.com/KARTOD/AAVE-Liquidations
- https://aavescan.com/
- https://dune.com/liquity/liquity-v2
- https://blog.chain.link/chainlink-smart-value-recapture-svr/
- https://www.liquity.org/blog/liquity-v2-bold-stability-pool-opportunities
- https://defillama.com/protocol/waterneuron
