//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Initialisable {
    bool private initialised;

    bool private initialising;

    modifier initialiser() {
        require(
            initialising || isConstructor() || !initialised,
            "Contract instance has already been initialised"
        );

        bool isTopLevelCall = !initialising;
        if (isTopLevelCall) {
            initialising = true;
            initialised = true;
        }

        _;

        if (isTopLevelCall) {
            initialising = false;
        }
    }

    function isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }

    uint256[50] private ______gap;
}