//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract VendingMachine {
    address payable public owner;
    uint public price;
    mapping(address => uint) public donutBalances;

    constructor(uint _price, uint _initialStock) payable{
        owner = payable(msg.sender);
        price = _price;
        donutBalances[address(this)] = _initialStock;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "Only the owner can access this function");
        _;
    }

    function getVendingMachineBalance() public view returns (uint) {
        return donutBalances[address(this)];
    }

    function changePrice(uint _price) public onlyOwner{
        price = _price;
    }

    function restock(uint amount) public onlyOwner{
        donutBalances[address(this)] += amount;
    }

    function purchase(uint amount) public payable {
        require(msg.value >= amount * price, "Send the correct amount");
        require(donutBalances[address(this)] >= amount, "Not enough donuts in stock to fulfill purchase request");
        donutBalances[address(this)] -= amount;
        donutBalances[msg.sender] += amount;
    }

    function withdraw() public onlyOwner{
        owner.transfer(address(this).balance);
    }
}
