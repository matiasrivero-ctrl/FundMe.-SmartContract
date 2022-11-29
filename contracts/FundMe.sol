// Get fund from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable{
        // Want to be able to set a minimum fund amount in USD
        //  1. How do we send ETH to this contract?
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough!"); // 1e18 == 1 * 10 ** 18 == 1000000000000000000
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {      
        /* starting index, ending index, step amount */
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            // code
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // reset the array
        funders = new address[](0);

        // actually withdraw the funds
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner  {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if(msg.sender != i_owner) revert NotOwner();
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}