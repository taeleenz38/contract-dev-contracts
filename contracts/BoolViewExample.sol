// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract BoolViewExample {
    bool private isActive = true;
    bool private isPaused = false;

    function getIsActive() public view returns (bool) {
        return isActive;
    }

    function getIsPaused() public view returns (bool) {
        return isPaused;
    }
}
