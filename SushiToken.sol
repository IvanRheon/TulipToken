// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SushiToken {
    string public name = "Sushi Token";
    string public symbol = "SUSHI";
    uint256 public totalSupply = 1000000;
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    address public owner; //添加 owner 变量

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Stake(address indexed staker, uint256 indexed amount, uint256 indexed unlockTime);
    event Unstake(address indexed unstaker, uint256 indexed amount);

    struct StakeStruct {
        uint256 amount;
        uint256 unlockTime;
    }

    StakeStruct[] public stakes;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender; //将 owner 初始化为合约部署者地址
    }
    
    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Not enough balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balanceOf[from] >= value, "Not enough balance");
        require(allowance[from][msg.sender] >= value, "Not enough allowance");
        balanceOf[from] -= value;
        allowance[from][msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    function stake(uint256 amount, uint256 time) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Not enough balance");
        balanceOf[msg.sender] -= amount;
        stakes.push(StakeStruct(amount, block.timestamp + time));
        emit Stake(msg.sender, amount, block.timestamp + time);
        return true;
    }

    function unstake() public returns (bool) {
        uint index = stakes.length - 1;
        require(index >= 0, "No stakes to unstake");
        StakeStruct memory stake = stakes[index];
        require(block.timestamp > stake.unlockTime, "Stake not yet unlocked");
        balanceOf[msg.sender] += stake.amount;
        stakes.pop();
        emit Unstake(msg.sender, stake.amount);
        return true;
    }
    
    modifier onlyOwner() { //添加 onlyOwner 权限修饰符
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner { //添加转移所有权函数
        owner = newOwner;
    }
}
