// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./ContractDevLogger.sol";

contract ContractDevLoggerTest {
    ContractDevLogger public logger;
    address public owner;

    // Simple log events
    event SimpleUint(uint256 indexed value);
    event SimpleAddress(address indexed addr);
    event SimpleUintAddress(uint256 indexed value, address indexed addr);

    // Struct definitions
    struct User {
        address userAddress;
        uint256 userId;
        string username;
        bool isActive;
    }

    struct Transaction {
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
        bytes32 txHash;
    }

    struct Order {
        uint256 orderId;
        address buyer;
        address seller;
        uint256 price;
        string itemName;
        bool isFulfilled;
    }

    // Events with structs
    event LogUser(User user);
    event LogUserIndexed(address indexed userAddress, uint256 indexed userId, string username, bool isActive);
    event LogTransaction(Transaction transaction);
    event LogTransactionIndexed(
        address indexed from,
        address indexed to,
        uint256 indexed amount,
        uint256 timestamp,
        bytes32 txHash
    );
    event LogOrder(Order order);
    event LogOrderIndexed(
        uint256 indexed orderId,
        address indexed buyer,
        address indexed seller,
        uint256 price,
        string itemName,
        bool isFulfilled
    );

    // Event with nested structs
    struct UserProfile {
        User user;
        uint256 balance;
        uint256 lastActivity;
    }

    event LogUserProfile(UserProfile profile);

    // Event with array of structs
    event LogUsers(User[] users);
    event LogTransactions(Transaction[] transactions);

    constructor(address _loggerAddress) {
        owner = msg.sender;
        logger = ContractDevLogger(_loggerAddress);
        
        // Emit simple logs
        emit SimpleAddress(msg.sender);
        emit SimpleUint(block.timestamp);
        
        // Call logger to test nested calls
        logger.logString("ContractDevLoggerTest initialized");
        logger.logAddress(msg.sender, "Test contract owner");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Simple log functions
    function emitSimpleUint(uint256 _value) public {
        emit SimpleUint(_value);
        
        // Nested call to logger
        logger.logUint(_value, "Simple uint logged");
    }

    function emitSimpleAddress(address _addr) public {
        emit SimpleAddress(_addr);
        
        // Nested call to logger
        logger.logAddress(_addr, "Simple address logged");
    }

    function emitSimpleUintAddress(uint256 _value, address _addr) public {
        emit SimpleUintAddress(_value, _addr);
        
        // Nested call to logger
        logger.logMultiple(_value, "Simple uint and address logged", true);
    }

    // Struct log functions
    function emitUserLog(
        address _userAddress,
        uint256 _userId,
        string memory _username,
        bool _isActive
    ) public {
        User memory user = User({
            userAddress: _userAddress,
            userId: _userId,
            username: _username,
            isActive: _isActive
        });

        emit LogUser(user);
        emit LogUserIndexed(_userAddress, _userId, _username, _isActive);
        
        // Nested calls to logger
        logger.logAddress(_userAddress, "User address from struct");
        logger.logUint(_userId, "User ID from struct");
        logger.logString(_username);
        logger.logBool(_isActive, "User active status");
    }

    function emitTransactionLog(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _timestamp,
        bytes32 _txHash
    ) public {
        Transaction memory tx = Transaction({
            from: _from,
            to: _to,
            amount: _amount,
            timestamp: _timestamp,
            txHash: _txHash
        });

        emit LogTransaction(tx);
        emit LogTransactionIndexed(_from, _to, _amount, _timestamp, _txHash);
        
        // Nested calls to logger
        logger.logAddress(_from, "Transaction from");
        logger.logAddress(_to, "Transaction to");
        logger.logUint(_amount, "Transaction amount");
        logger.logUint(_timestamp, "Transaction timestamp");
        logger.logInfo("Transaction", "Transaction logged with struct");
    }

    function emitOrderLog(
        uint256 _orderId,
        address _buyer,
        address _seller,
        uint256 _price,
        string memory _itemName,
        bool _isFulfilled
    ) public {
        Order memory order = Order({
            orderId: _orderId,
            buyer: _buyer,
            seller: _seller,
            price: _price,
            itemName: _itemName,
            isFulfilled: _isFulfilled
        });

        emit LogOrder(order);
        emit LogOrderIndexed(_orderId, _buyer, _seller, _price, _itemName, _isFulfilled);
        
        // Nested calls to logger
        logger.logUint(_orderId, "Order ID");
        logger.logAddress(_buyer, "Order buyer");
        logger.logAddress(_seller, "Order seller");
        logger.logUint(_price, "Order price");
        logger.logString(_itemName);
        logger.logBool(_isFulfilled, "Order fulfilled status");
    }

    // Nested struct log function
    function emitUserProfileLog(
        address _userAddress,
        uint256 _userId,
        string memory _username,
        bool _isActive,
        uint256 _balance,
        uint256 _lastActivity
    ) public {
        User memory user = User({
            userAddress: _userAddress,
            userId: _userId,
            username: _username,
            isActive: _isActive
        });

        UserProfile memory profile = UserProfile({
            user: user,
            balance: _balance,
            lastActivity: _lastActivity
        });

        emit LogUserProfile(profile);
        
        // Nested calls to logger
        logger.logInfo("UserProfile", "Nested struct logged");
        logger.logAddress(_userAddress, "Profile user address");
        logger.logUint(_balance, "Profile balance");
        logger.logUint(_lastActivity, "Profile last activity");
    }

    // Array of structs log function
    function emitUsersLog(
        address[] memory _addresses,
        uint256[] memory _userIds,
        string[] memory _usernames,
        bool[] memory _activeStatuses
    ) public {
        require(
            _addresses.length == _userIds.length &&
            _userIds.length == _usernames.length &&
            _usernames.length == _activeStatuses.length,
            "Array lengths must match"
        );

        User[] memory users = new User[](_addresses.length);
        
        for (uint256 i = 0; i < _addresses.length; i++) {
            users[i] = User({
                userAddress: _addresses[i],
                userId: _userIds[i],
                username: _usernames[i],
                isActive: _activeStatuses[i]
            });
        }

        emit LogUsers(users);
        
        // Nested calls to logger
        logger.logUint(_addresses.length, "Number of users in array");
        logger.logString("Batch users logged");
    }

    function emitTransactionsLog(
        address[] memory _froms,
        address[] memory _tos,
        uint256[] memory _amounts,
        uint256[] memory _timestamps,
        bytes32[] memory _txHashes
    ) public {
        require(
            _froms.length == _tos.length &&
            _tos.length == _amounts.length &&
            _amounts.length == _timestamps.length &&
            _timestamps.length == _txHashes.length,
            "Array lengths must match"
        );

        Transaction[] memory transactions = new Transaction[](_froms.length);
        
        for (uint256 i = 0; i < _froms.length; i++) {
            transactions[i] = Transaction({
                from: _froms[i],
                to: _tos[i],
                amount: _amounts[i],
                timestamp: _timestamps[i],
                txHash: _txHashes[i]
            });
        }

        emit LogTransactions(transactions);
        
        // Nested calls to logger
        logger.logUint(_froms.length, "Number of transactions in array");
        logger.logInfo("Transactions", "Batch transactions logged");
    }

    // Complex function that combines everything
    function emitComplexLog(
        uint256 _value,
        address _addr,
        address _userAddress,
        uint256 _userId,
        string memory _username,
        bool _isActive
    ) public {
        // Emit simple logs
        emit SimpleUint(_value);
        emit SimpleAddress(_addr);
        
        // Emit struct log
        User memory user = User({
            userAddress: _userAddress,
            userId: _userId,
            username: _username,
            isActive: _isActive
        });
        emit LogUser(user);
        
        // Multiple nested calls to logger
        logger.logString("Starting complex log operation");
        logger.logUint(_value, "Complex log value");
        logger.logAddress(_addr, "Complex log address");
        logger.logAddress(_userAddress, "Complex log user address");
        logger.logUint(_userId, "Complex log user ID");
        logger.logString(_username);
        logger.logBool(_isActive, "Complex log active status");
        logger.logWithTimestamp("Complex log operation completed");
    }

    function updateLogger(address _newLoggerAddress) public onlyOwner {
        require(
            _newLoggerAddress != address(0),
            "New logger cannot be the zero address"
        );
        
        address oldLogger = address(logger);
        logger = ContractDevLogger(_newLoggerAddress);
        
        emit SimpleAddress(oldLogger);
        emit SimpleAddress(_newLoggerAddress);
        
        // Test nested call with new logger
        logger.logAddress(oldLogger, "Previous logger address");
        logger.logAddress(_newLoggerAddress, "New logger address");
    }
}

