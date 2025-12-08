// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract ContractDevLogger {
    address public owner;
    uint256 public logCount;

    event LogString(string message);
    event LogAddress(address indexed addr, string message);
    event LogUint(uint256 indexed value, string message);
    event LogBool(bool value, string message);
    event LogBytes(bytes data, string message);
    event LogMultiple(
        address indexed sender,
        uint256 indexed value,
        string message,
        bool flag
    );
    event LogWithTimestamp(
        uint256 indexed timestamp,
        address indexed sender,
        string message
    );
    event LogError(string message, address indexed sender);
    event LogInfo(
        string category,
        string message,
        address indexed sender,
        uint256 indexed timestamp
    );
    event LogCount(uint256 indexed count, string message);

    constructor() {
        owner = msg.sender;
        logCount = 0;
        emit LogString("ContractDevLogger initialized");
        emit LogAddress(msg.sender, "Owner set");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function logString(string memory _message) public {
        logCount++;
        emit LogString(_message);
        emit LogCount(logCount, "String log emitted");
    }

    function logAddress(address _addr, string memory _message) public {
        logCount++;
        emit LogAddress(_addr, _message);
        emit LogCount(logCount, "Address log emitted");
    }

    function logUint(uint256 _value, string memory _message) public {
        logCount++;
        emit LogUint(_value, _message);
        emit LogCount(logCount, "Uint log emitted");
    }

    function logBool(bool _value, string memory _message) public {
        logCount++;
        emit LogBool(_value, _message);
        emit LogCount(logCount, "Bool log emitted");
    }

    function logBytes(bytes memory _data, string memory _message) public {
        logCount++;
        emit LogBytes(_data, _message);
        emit LogCount(logCount, "Bytes log emitted");
    }

    function logMultiple(
        uint256 _value,
        string memory _message,
        bool _flag
    ) public {
        logCount++;
        emit LogMultiple(msg.sender, _value, _message, _flag);
        emit LogCount(logCount, "Multiple log emitted");
    }

    function logWithTimestamp(string memory _message) public {
        logCount++;
        emit LogWithTimestamp(block.timestamp, msg.sender, _message);
        emit LogCount(logCount, "Timestamp log emitted");
    }

    function logError(string memory _message) public {
        logCount++;
        emit LogError(_message, msg.sender);
        emit LogCount(logCount, "Error log emitted");
    }

    function logInfo(string memory _category, string memory _message) public {
        logCount++;
        emit LogInfo(_category, _message, msg.sender, block.timestamp);
        emit LogCount(logCount, "Info log emitted");
    }

    function logBatch(string[] memory _messages) public {
        for (uint256 i = 0; i < _messages.length; i++) {
            logCount++;
            emit LogString(_messages[i]);
        }
        emit LogCount(logCount, "Batch logs emitted");
    }

    function resetLogCount() public onlyOwner {
        uint256 oldCount = logCount;
        logCount = 0;
        emit LogUint(oldCount, "Log count reset from");
        emit LogUint(logCount, "Log count reset to");
    }

    function updateOwner(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0),
            "New owner cannot be the zero address"
        );
        address oldOwner = owner;
        owner = _newOwner;
        emit LogAddress(oldOwner, "Previous owner");
        emit LogAddress(_newOwner, "New owner set");
    }
}

