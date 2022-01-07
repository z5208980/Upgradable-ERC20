### Contracts
Most of the smart contract is based on Openzeppelin's implementation. The roles of each smart contract are as follows,
- `Initialisable.sol`, used in place of `constructor()` to ensure initialisation of contract occurs once.
-  `SafeMath.sol`, handle math operations safely, especially in ERC20 tokens.
- `ERC20.sol`, Basic ERC20 functionality with `Initialisable` constructor.
- `ERC20V2.sol`, Implementation of ERC20 with `burn(uint256 amount)` feature that receive 90% ETH of value burnt.
- `Proxy.sol`, acts as the delegator to store the state and logic of the ERC20 tokens

### General Information
**Have an owner account that can upgrade the smart contract**

Ownership of the contract is managed in `Proxy.sol`. For this I've implemented getters `getProxyOwner()` and setters `setProxyOwnership(address)` for simple transfer of owner account that can **only** be made by the current proxy owner.

**Implements ERC20**

Basic ERC20 `ERC20.sol` which is `Initialisable.sol` that is used for initilisation of constructor `intilise()` instead of regularly `constructor`.

**Anyone can send ETH to this smart contract to mint the same amount of ERC20 tokens**

`ERC20.sol` should have `mint()` which depends on `msg.value`. Amount obtained will be held by the smart contract, then mine ERC20 tokens as `msg.value` amount and given to `msg.sender`.

**Have a kill switch that permanently kills upgrade functionality. Only the owner can perform this action.**

In `Proxy.sol`. Simple `bool` variable is stored with the method `upgradeKill()` that can only be called **once** and by proxy owner.

**Deploy this smart contract to Kovan testnet**
- **Proxy**:  `0x7fa002BF1a2fBff36E4cE8eDB3443A95aadA9485` [Etherscan address](https://kovan.etherscan.io/address/0x7fa002BF1a2fBff36E4cE8eDB3443A95aadA9485) 
- **ERC20**: `0x15819e2FaAA2fB1e81eb1EF1AaF57738f31aA767` [Etherscan address](https://kovan.etherscan.io/address/0x15819e2FaAA2fB1e81eb1EF1AaF57738f31aA767) 
    - *This one doesn't get interacted*
- **ERC20V2**: `0xF288EA1D2b8Ca9de9eC95714b44e1E6d71b9DC4F` [Etherscan address](https://kovan.etherscan.io/address/0xF288EA1D2b8Ca9de9eC95714b44e1E6d71b9DC4F) 
    - *This one doesn't get interacted*

**Make a transaction to send ETH to mint ERC20 token**
- **Transaction**:  [Etherscan tx](https://kovan.etherscan.io/tx/0x0c9d871cc1d6b079912a50a361dc542701a1d9ca6a9c4668bc036ff71e38f935)

**Upgrade the smart contract to add a feature that allow user to burn ERC20 token and get 90% of the ETH back**

The upgrade of the ERC20 token occurs in the `Proxy.sol` using `upgradeTo(address)` that takes in the ERC20 address implementations. For this case, a new ERC20 called `ERC20V2.sol` will be the upgraded contract that gets implemented in the proxy that has the addition `burn(address, amount)` to burn the ERC20 and receive 90% of the burnt value back in ETH.

**Submit all the relevant code, including pre-upgraded contract and all the executed transactions' hash, preferably etherscan links to the transactions**
-   Transaction deploys smart contract [Etherscan tx](https://kovan.etherscan.io/tx/0xca5400660ce8e82a66da7494c4a86dfb39dafe698ea4302edb0e70869f60ab9e)
-   Transaction sends ETH to mint ERC20 token [Etherscan tx](https://kovan.etherscan.io/tx/0x0c9d871cc1d6b079912a50a361dc542701a1d9ca6a9c4668bc036ff71e38f935)
    - 0.05 ETH => 0.05 ERC20
-   Transaction performs upgrade [Etherscan tx](https://kovan.etherscan.io/tx/0xc077e2b42d25eaf697b0cabb6d1ded6f095cddc547b029159492b89f7583237f)
-   Transaction performs kill switch
    -  [Etherscan tx](https://kovan.etherscan.io/tx/0x372532cd24d839b0bc2bf26a39c83cad4bc416f449051315b1deb62a94ac5dc5)
    - Force upgrade another ERC20 implementation fail: [Etherscan tx](https://kovan.etherscan.io/tx/0x566d844e6a151d494239d8fef067b4899e005c64aa02f37e9f0ab220246ca6b9)
-   Transaction that burn ERC20 token and receive ETH [Etherscan tx](https://kovan.etherscan.io/tx/0xf59fb0ab24a6b33e8e0e63ee5415348be2b56fb93480e62dd1e7ef0a2fb06279)
    - 0.05 ERC20 => 0.045 ETH (the 0.005 ETH remains in smart contract) 
