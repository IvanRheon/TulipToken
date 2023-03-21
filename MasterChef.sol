// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./SushiToken.sol";
contract MasterChef {
    IERC20 public token;

    uint256 public totalStaked;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public lastStakedTime;
    mapping(address => uint256) public rewards;
    address public admin;

    struct LPInfo {
        IERC20 lpToken;
        string name;
    }

    LPInfo[] public lpTokens;

    constructor(address _token) {
        token = IERC20(_token);
        admin = msg.sender;
    }

    function stake(uint256 amount) public {
        require(amount > 0, "Amount cannot be zero.");
        token.transferFrom(msg.sender, address(this), amount);
        if (stakedBalance[msg.sender] == 0) {
            lastStakedTime[msg.sender] = block.timestamp;
        }
        stakedBalance[msg.sender] += amount;
        totalStaked += amount;
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Amount cannot be zero.");
        require(stakedBalance[msg.sender] >= amount, "Insufficient balance.");
        require(lastStakedTime[msg.sender] + 86400 <= block.timestamp, "Lock-up is active. Please wait for 24 hours.");
        token.transfer(msg.sender, amount);
        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;
    }

    function claimReward() public {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards to claim.");
        rewards[msg.sender] = 0;
        token.transfer(msg.sender, reward);
    }

    function calculateReward(address user) public view returns (uint256) {
        uint256 timeDifference = block.timestamp - lastStakedTime[user];
        uint256 stakingReward = (stakedBalance[user] * 1 * timeDifference) / 86400 / 100;

        uint256 totalReward = stakingReward + rewards[user];
        return totalReward;
    }

    function setAdmin(address newAdmin) public {
         require(msg.sender == admin, "Only admin can perform this action.");
         admin = newAdmin;
    }

    function rescueTokens(IERC20 tokenToRescue, uint256 amount) public {
        require(msg.sender == admin, "Only admin can perform this action.");
        tokenToRescue.transfer(msg.sender, amount);
    }

    function add (IERC20 _lpToken, string memory _name) public {
        require (msg.sender == admin, "Only the admin can add LP tokens.");
        lpTokens.push(LPInfo({
            lpToken: _lpToken,
            name: _name
        }));
    }
}
