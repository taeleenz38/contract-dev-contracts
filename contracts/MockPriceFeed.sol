// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract MockPriceFeed {
    int256 public value;
    int8 public valueInt8;
    int16 public valueInt16;
    int32 public valueInt32;
    int64 public valueInt64;
    int128 public valueInt128;

    function setPrice(int256 _value) public {
        value = _value;
    }

    function setInts(
        int8 _valueInt8,
        int16 _valueInt16,
        int32 _valueInt32,
        int64 _valueInt64,
        int128 _valueInt128
    ) public {
        valueInt8 = _valueInt8;
        valueInt16 = _valueInt16;
        valueInt32 = _valueInt32;
        valueInt64 = _valueInt64;
        valueInt128 = _valueInt128;
    }
}
