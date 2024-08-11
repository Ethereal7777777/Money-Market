// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LendingContract is Ownable {
    IERC20 public lendingToken;
    uint256 public interestRate; // Interest rate per block

    struct Deposit {
        uint256 amount;
        uint256 depositBlock;
    }

    mapping(address => Deposit) public deposits;
    mapping(address => uint256) public borrowBalances;

    constructor(IERC20 _lendingToken, uint256 _interestRate) {
        lendingToken = _lendingToken;
        interestRate = _interestRate;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");
        lendingToken.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender].amount += amount;
        deposits[msg.sender].depositBlock = block.number;
    }

    function withdraw() external {
        require(deposits[msg.sender].amount > 0, "No deposit to withdraw");
        uint256 blocksPassed = block.number - deposits[msg.sender].depositBlock;
        uint256 interest = (deposits[msg.sender].amount * interestRate * blocksPassed) / 1e18;
        uint256 totalAmount = deposits[msg.sender].amount + interest;

        deposits[msg.sender].amount = 0;
        lendingToken.transfer(msg.sender, totalAmount);
    }

    function borrow(uint256 amount) external {
        require(amount > 0, "Borrow amount must be greater than zero");
        borrowBalances[msg.sender] += amount;
        lendingToken.transfer(msg.sender, amount);
    }

    function repay(uint256 amount) external {
        require(amount > 0, "Repay amount must be greater than zero");
        require(borrowBalances[msg.sender] >= amount, "Repay amount exceeds borrowed amount");

        borrowBalances[msg.sender] -= amount;
        lendingToken.transferFrom(msg.sender, address(this), amount);
    }

    function setInterestRate(uint256 _interestRate) external onlyOwner {
        interestRate = _interestRate;
    }
}
