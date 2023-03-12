//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract oya{

    mapping(address => uint256) public addressToAmountFunded;
    address public owner;
    address[] public funders;

    constructor() public{
        owner=msg.sender;
    }

    function pesa() public payable {
    uint256 minUSD = 50 * 10 ** 18;

    require(getConversionRate(msg.value)>=minUSD,"You need more ETH for this transaction to folllow");

    addressToAmountFunded[msg.sender] += msg.value;

    funders.push(msg.sender);

    }
    function getVersion() public view returns(uint256)
    {
        AggregatorV3Interface pricefeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return pricefeed.version();
    }
    function getPrice() public view returns(uint256)
    {
        AggregatorV3Interface prices = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
       
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = prices.latestRoundData();    
        return uint256(answer * 10000000000);
    }
    function getConversionRate(uint256 ethAmount) public view returns(uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount)/1000000000000000000;
        return ethAmountInUsd;
    }
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    function withdraw() public onlyOwner{
       // msg.sender.transfer(address(this).balance);
        //uint256 ejectMinUSD = 10 * 10 ** 18;
        //require(msg.sender == owner); //can't run if the owner has not authorized
        payable(msg.sender).transfer(address(this).balance);
        for(uint256 funderIndex=0; funderIndex<funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;

        }
        funders = new address[](0);
    }
    
}
