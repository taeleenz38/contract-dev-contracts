// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IERC20Minimal {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract MockERC20 {
    string public name = "QA Token";
    string public symbol = "QAT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function mint(address to, uint256 amount) external {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= amount, "ERC20: insufficient allowance");

        allowance[from][msg.sender] = allowed - amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(balanceOf[from] >= amount, "ERC20: insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
}

contract SimulationQAHarness {
    struct UserRecord {
        uint256 visits;
        uint256 lastValue;
        string tag;
    }

    uint256 public number;
    string public note;
    address public lastCaller;
    uint256 public callCount;
    bool public lastCallSuccess;
    bytes public lastCallData;
    bytes public lastReturnData;

    mapping(address => uint256) public credits;
    mapping(bytes32 => bytes32) public bytes32Store;
    mapping(address => UserRecord) private userRecords;
    uint256[] public checkpoints;

    event NativeReceived(address indexed sender, uint256 amount, uint256 newContractBalance);
    event NativeWithdrawn(address indexed to, uint256 amount, uint256 newContractBalance);
    event ValueUpdated(uint256 number, string note, address indexed caller);
    event CreditUpdated(address indexed account, uint256 value);
    event RecordUpdated(address indexed account, uint256 visits, uint256 lastValue, string tag);
    event ExternalCall(
        address indexed target,
        uint256 value,
        bytes data,
        bool success,
        bytes returnData
    );

    receive() external payable {
        emit NativeReceived(msg.sender, msg.value, address(this).balance);
    }

    function depositNative() external payable {
        emit NativeReceived(msg.sender, msg.value, address(this).balance);
    }

    function withdrawNative(address payable to, uint256 amount) external {
        require(address(this).balance >= amount, "insufficient native balance");
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "native transfer failed");
        emit NativeWithdrawn(to, amount, address(this).balance);
    }

    function contractNativeBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function erc20Balance(address token, address account) external view returns (uint256) {
        return IERC20Minimal(token).balanceOf(account);
    }

    function pullERC20(address token, address from, uint256 amount) external {
        bool ok = IERC20Minimal(token).transferFrom(from, address(this), amount);
        require(ok, "transferFrom failed");
    }

    function pushERC20(address token, address to, uint256 amount) external {
        bool ok = IERC20Minimal(token).transfer(to, amount);
        require(ok, "transfer failed");
    }

    function approveERC20(address token, address spender, uint256 amount) external {
        bool ok = IERC20Minimal(token).approve(spender, amount);
        require(ok, "approve failed");
    }

    function setValues(uint256 newNumber, string calldata newNote) external {
        number = newNumber;
        note = newNote;
        lastCaller = msg.sender;
        callCount += 1;
        emit ValueUpdated(newNumber, newNote, msg.sender);
    }

    function setCredit(address account, uint256 value) external {
        credits[account] = value;
        emit CreditUpdated(account, value);
    }

    function incrementCredit(address account, uint256 delta) external {
        credits[account] += delta;
        emit CreditUpdated(account, credits[account]);
    }

    function setBytes32(bytes32 key, bytes32 value) external {
        bytes32Store[key] = value;
    }

    function pushCheckpoint(uint256 value) external {
        checkpoints.push(value);
    }

    function checkpointCount() external view returns (uint256) {
        return checkpoints.length;
    }

    function setRecord(uint256 value, string calldata tag) external {
        UserRecord storage record = userRecords[msg.sender];
        record.visits += 1;
        record.lastValue = value;
        record.tag = tag;

        emit RecordUpdated(msg.sender, record.visits, record.lastValue, record.tag);
    }

    function getRecord(address account) external view returns (UserRecord memory) {
        return userRecords[account];
    }

    function execute(address target, uint256 value, bytes calldata data)
        external
        payable
        returns (bool success, bytes memory returnData)
    {
        (success, returnData) = target.call{value: value}(data);
        _recordExternalCall(target, value, data, success, returnData);
    }

    function executeDelegate(address target, bytes calldata data)
        external
        returns (bool success, bytes memory returnData)
    {
        (success, returnData) = target.delegatecall(data);
        _recordExternalCall(target, 0, data, success, returnData);
    }

    function multicall(bytes[] calldata calls) external returns (bytes[] memory results) {
        results = new bytes[](calls.length);

        for (uint256 i = 0; i < calls.length; i++) {
            (bool ok, bytes memory res) = address(this).delegatecall(calls[i]);
            require(ok, "multicall item failed");
            results[i] = res;
        }
    }

    function revertAlways(string calldata reason) external pure {
        revert(reason);
    }

    function _recordExternalCall(
        address target,
        uint256 value,
        bytes memory data,
        bool success,
        bytes memory returnData
    ) internal {
        lastCaller = msg.sender;
        callCount += 1;
        lastCallSuccess = success;
        lastCallData = data;
        lastReturnData = returnData;

        emit ExternalCall(target, value, data, success, returnData);
    }
}
