//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "contracts/PriceConverter.sol";

error FundMe__NotOwner();

/** @title A contract for crowd funding
 *  @author Kidus Abebe
 *  @dev This implements price feeds as our library
 */
contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINUSD = 50 * 1e18;
    uint256 public valInUSD;

    address private immutable i_owner;
    address[] private s_funders;
    mapping(address => uint256) private s_addrToAmtFund;

    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Your not owner");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        require(
            msg.value.getConvertedRate(s_priceFeed) >= MINUSD,
            "Didn't send enough!"
        );
        s_funders.push(msg.sender);
        s_addrToAmtFund[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        // require(msg.sender == owner,"Your not owner");
        address[] memory funders = s_funders;

        for (uint256 funderIdx = 0; funderIdx < funders.length; funderIdx++) {
            address funder = funders[funderIdx];
            s_addrToAmtFund[funder] = 0;
        }

        s_funders = new address[](0);

        //Transfer
        // payable(msg.sender).transfer(address(this).balance);
        //send
        // bool status = payable(msg.sender).send(address(this).balance);
        // require(status, "Fail!");
        //call
        (bool callStatus, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callStatus, "Fail!");
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunders(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddrToAmount(address funder) public view returns (uint256) {
        return s_addrToAmtFund[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
