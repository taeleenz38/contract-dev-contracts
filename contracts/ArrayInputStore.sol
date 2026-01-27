// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract ArrayInputStore {
    uint256[] public numbers;
    address[] public addresses;

    constructor(uint256[] memory _numbers, address[] memory _addresses) {
        numbers = _numbers;
        addresses = _addresses;
    }

    function getNumbers() public view returns (uint256[] memory) {
        return numbers;
    }

    function getAddresses() public view returns (address[] memory) {
        return addresses;
    }
}
