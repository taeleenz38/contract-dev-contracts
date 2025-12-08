// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract ContractDevWETHDepositor {
    address public owner;
    address public wethAddress;
    IWETH public weth;
    
    uint256 public totalETHDeposited;
    uint256 public totalWETHDeposited;
    uint256 public totalWETHWithdrawn;
    
    mapping(address => uint256) public userWETHBalance;
    mapping(address => uint256) public userETHDeposited;
    
    struct Deposit {
        address user;
        uint256 ethAmount;
        uint256 wethAmount;
        uint256 timestamp;
    }
    
    mapping(uint256 => Deposit) public deposits;
    uint256 public depositCount;
    
    event ETHReceived(address indexed sender, uint256 amount);
    event ETHDepositedToWETH(
        address indexed user,
        uint256 ethAmount,
        uint256 wethAmount
    );
    event WETHWithdrawn(
        address indexed user,
        uint256 wethAmount,
        uint256 ethAmount
    );
    event WETHTransferred(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    event WETHAddressUpdated(address indexed oldAddress, address indexed newAddress);

    constructor(address _wethAddress) {
        owner = msg.sender;
        require(_wethAddress != address(0), "WETH address cannot be zero");
        wethAddress = _wethAddress;
        weth = IWETH(_wethAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Receive ETH and automatically deposit to WETH
    receive() external payable {
        require(msg.value > 0, "Must send ETH");
        _depositToWETH(msg.sender, msg.value);
    }

    // Fallback function for ETH
    fallback() external payable {
        if (msg.value > 0) {
            _depositToWETH(msg.sender, msg.value);
        }
    }

    // Manual deposit function
    function depositETH() public payable {
        require(msg.value > 0, "Must send ETH");
        _depositToWETH(msg.sender, msg.value);
    }

    // Internal function to handle WETH deposit
    function _depositToWETH(address _user, uint256 _ethAmount) internal {
        // Get WETH balance before deposit
        uint256 wethBalanceBefore = weth.balanceOf(address(this));
        
        // Deposit ETH to WETH contract
        weth.deposit{value: _ethAmount}();
        
        // Get the WETH amount received (should be 1:1 with ETH)
        uint256 wethBalanceAfter = weth.balanceOf(address(this));
        uint256 wethAmount = wethBalanceAfter - wethBalanceBefore;
        
        // Update balances
        userWETHBalance[_user] += wethAmount;
        userETHDeposited[_user] += _ethAmount;
        totalETHDeposited += _ethAmount;
        totalWETHDeposited += wethAmount;
        
        // Record deposit
        deposits[depositCount] = Deposit({
            user: _user,
            ethAmount: _ethAmount,
            wethAmount: wethAmount,
            timestamp: block.timestamp
        });
        depositCount++;
        
        emit ETHReceived(_user, _ethAmount);
        emit ETHDepositedToWETH(_user, _ethAmount, wethAmount);
    }

    // Withdraw WETH back to ETH
    function withdrawWETH(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            userWETHBalance[msg.sender] >= _amount,
            "Insufficient WETH balance"
        );
        require(
            weth.balanceOf(address(this)) >= _amount,
            "Contract has insufficient WETH"
        );
        
        // Update balances
        userWETHBalance[msg.sender] -= _amount;
        totalWETHWithdrawn += _amount;
        
        // Withdraw WETH to ETH
        weth.withdraw(_amount);
        
        // Transfer ETH to user
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "ETH transfer failed");
        
        emit WETHWithdrawn(msg.sender, _amount, _amount);
    }

    // Withdraw all WETH for user
    function withdrawAllWETH() public {
        uint256 balance = userWETHBalance[msg.sender];
        require(balance > 0, "No WETH balance to withdraw");
        withdrawWETH(balance);
    }

    // Transfer WETH to another address (transfers within this contract's tracking system)
    function transferWETH(address _to, uint256 _amount) public {
        require(_to != address(0), "Cannot transfer to zero address");
        require(_amount > 0, "Amount must be greater than 0");
        require(
            userWETHBalance[msg.sender] >= _amount,
            "Insufficient WETH balance"
        );
        require(
            weth.balanceOf(address(this)) >= _amount,
            "Contract has insufficient WETH"
        );
        
        // Update balances (WETH stays in contract, just tracking changes)
        userWETHBalance[msg.sender] -= _amount;
        userWETHBalance[_to] += _amount;
        
        emit WETHTransferred(msg.sender, _to, _amount);
    }
    
    // Transfer WETH tokens out of the contract to an external address
    function transferWETHToExternal(address _to, uint256 _amount) public {
        require(_to != address(0), "Cannot transfer to zero address");
        require(_amount > 0, "Amount must be greater than 0");
        require(
            userWETHBalance[msg.sender] >= _amount,
            "Insufficient WETH balance"
        );
        require(
            weth.balanceOf(address(this)) >= _amount,
            "Contract has insufficient WETH"
        );
        
        // Update balance
        userWETHBalance[msg.sender] -= _amount;
        
        // Transfer WETH tokens to external address
        require(
            weth.transfer(_to, _amount),
            "WETH transfer failed"
        );
        
        emit WETHTransferred(msg.sender, _to, _amount);
    }

    // Get user's WETH balance
    function getUserWETHBalance(address _user) public view returns (uint256) {
        return userWETHBalance[_user];
    }

    // Get contract's total WETH balance
    function getContractWETHBalance() public view returns (uint256) {
        return weth.balanceOf(address(this));
    }

    // Get contract's ETH balance
    function getContractETHBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Get deposit info
    function getDeposit(uint256 _depositId) public view returns (
        address user,
        uint256 ethAmount,
        uint256 wethAmount,
        uint256 timestamp
    ) {
        require(_depositId < depositCount, "Deposit does not exist");
        Deposit memory deposit = deposits[_depositId];
        return (
            deposit.user,
            deposit.ethAmount,
            deposit.wethAmount,
            deposit.timestamp
        );
    }

    // Owner functions
    function updateWETHAddress(address _newWETHAddress) public onlyOwner {
        require(_newWETHAddress != address(0), "WETH address cannot be zero");
        address oldAddress = wethAddress;
        wethAddress = _newWETHAddress;
        weth = IWETH(_newWETHAddress);
        emit WETHAddressUpdated(oldAddress, _newWETHAddress);
    }

    function updateOwner(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0),
            "New owner cannot be the zero address"
        );
        address oldOwner = owner;
        owner = _newOwner;
        emit OwnerChanged(oldOwner, _newOwner);
    }

    // Emergency function to withdraw any stuck ETH (only owner)
    function emergencyWithdrawETH(uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Insufficient ETH balance");
        (bool success, ) = payable(owner).call{value: _amount}("");
        require(success, "ETH transfer failed");
    }
}

