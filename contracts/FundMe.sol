//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "contracts/PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINUSD = 50 * 1e18;
    uint256 public valInUSD;

    address public immutable i_owner;
    address[] public funders;
    mapping(address => uint256) public addrToAmtFund;

    AggregatorV3Interface public priceFeed;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        require(
            msg.value.getConvertedRate(priceFeed) >= MINUSD,
            "Didn't send enough!"
        );
        funders.push(msg.sender);
        addrToAmtFund[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        // require(msg.sender == owner,"Your not owner");
        for (uint256 funderIdx = 0; funderIdx < funders.length; funderIdx++) {
            address funder = funders[funderIdx];
            addrToAmtFund[funder] = 0;
        }

        funders = new address[](0);

        //Transfer
        payable(msg.sender).transfer(address(this).balance);
        //send
        bool status = payable(msg.sender).send(address(this).balance);
        require(status, "Fail!");
        //call
        (bool callStatus, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callStatus, "Fail!");
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Your not owner");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
