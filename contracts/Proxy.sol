//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// import "./Initialisable.sol";
// contract Proxy is Initialisable {

contract Proxy {
    bytes32 private constant IMPLEMENTATION_MEMORY_ADDR = keccak256("implementation_address");
    bytes32 private constant PROXY_OWNER_MEMORY_ADDR = keccak256("proxy_owner");
    bytes32 private constant UPGRADABLE_MEMORY_ADDR = keccak256("upgradability");

    event Upgraded(address oldImplementation, address newImplementation);

    constructor() {
        bytes32 ownerPosition = PROXY_OWNER_MEMORY_ADDR;
        bytes32 upgradablePosition = UPGRADABLE_MEMORY_ADDR;

        address me = msg.sender;
        assembly { 
            sstore(ownerPosition, me) 
            sstore(upgradablePosition, true) 

        }
    }

    /*
     * getter, setter and modifier for proxy owner
     */
    function getProxyOwner() public view returns (address owner) {
        bytes32 position = PROXY_OWNER_MEMORY_ADDR;
        assembly { owner := sload(position) }
    }

    function setProxyOwnership(address newProxyOwner) public onlyProxyOwner {
        require(newProxyOwner != address(0), "Proxy: Proxy: New Address can not be address(0)");
        bytes32 position = PROXY_OWNER_MEMORY_ADDR;
        assembly { sstore(position, newProxyOwner) }    
    }

    modifier onlyProxyOwner() {
        require(msg.sender == getProxyOwner(), "Proxy: Not Proxy owner");
        _;
    }

    /*
     * getter, setter, upgrade and to kill logic contract
     */
    function getImplementation() public view returns (address owner) {
        bytes32 position = IMPLEMENTATION_MEMORY_ADDR;
        assembly { owner := sload(position) }
    }

    function setImplementation(address newImplementation) private onlyUpgradeable onlyProxyOwner {
        bytes32 position = IMPLEMENTATION_MEMORY_ADDR;
        assembly { sstore(position, newImplementation) }    
    }

    function upgradeTo(address implementation) public onlyUpgradeable onlyProxyOwner {
        require(implementation != address(0), "Proxy: New Address can not be address(0)");
        require(getImplementation() != implementation, "Proxy: New Address can not match current Implementation");
        setImplementation(implementation);
        emit Upgraded(getImplementation(), implementation);
    }

    // Perform kill switch to kill upgrade functionality
    function upgradeKill() public onlyUpgradeable onlyProxyOwner {
        bytes32 position = UPGRADABLE_MEMORY_ADDR;
        assembly { sstore(position, false) }    
    }

    function getUpgradable() public view returns (bool upgradable) {
        bytes32 position = UPGRADABLE_MEMORY_ADDR;
        assembly { upgradable := sload(position) }
    }

    modifier onlyUpgradeable() {
        require(getUpgradable() == true, "Proxy: Not upgradable");
        _;
    }

    /*
     * function to call the logic with ERC20 tokens
     */
    uint256 public ethBalances;
    fallback() external payable {
        address impl = getImplementation();
        ethBalances = msg.value;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)

            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    bool wasHere;
    receive() external payable {
        wasHere = true;
    }
}