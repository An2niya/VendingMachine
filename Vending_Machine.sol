//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract VendingMachine {
    address public owner;
    mapping(address => uint) public donutBalances;
    uint public price;

    
    event Sale(uint amount, uint left, address buyer);
    event Restock(uint oldBalance, uint newBalance);

    constructor(uint amount) {
        owner = msg.sender;
        donutBalances[address(this)] = amount;
        price = 2 ether;
    }

    /// @dev checks if amount is valid
    modifier checkAmount(uint amount){
        require(amount > 1, "amount needs to be at least one");
        _;
    }

    /// @dev returns the number of donuts available
    function getVendingMachineBalance() public view returns (uint) {
        return donutBalances[address(this)];
    }

    /// @dev restocks the number of donuts callable only by the owner
    function restock(uint amount) external checkAmount(amount) {
        require(msg.sender == owner, "Only the owner can restock this machine.");
        uint oldBalance = donutBalances[address(this)]; 
        donutBalances[address(this)] += amount;
        emit Restock(oldBalance, donutBalances[address(this)]);
    }

    /// @dev allow users to purchase donuts by x amount
    function purchase(uint amount) external payable checkAmount(amount) {
        require(msg.sender != owner, "you can't buy your own donuts");
        require(donutBalances[address(this)] >= amount, "Not enough donuts in stock to fulfill purchase request");
        uint total = price * amount;
        require(msg.value == total, "You must pay at least 2 ether per donut");
        donutBalances[address(this)] -= amount;
        donutBalances[msg.sender] += amount;
        (bool success,) = payable(owner).call{value: total}("");
        require(success, "Transfer failed");
        emit Sale(amount, donutBalances[address(this)], msg.sender);
    }
}
