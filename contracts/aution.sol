//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
import "./interfaces/auctionInterface.sol";



contract Auction is IAuction{
   

    enum State {Started, Running,Ended, Canceled}
    State public auctionStatus;

    uint public highestBindingBid;
    address payable public highestBidder;

    mapping(address => uint) public bids;
    uint bidIncrement;

    address payable public owner;
    uint public startAuction;
    uint public endAuction;
    string public ipfsHash;


    constructor(){
        owner = payable(msg.sender);
        auctionStatus = State.Running;
        startAuction = block.number;
        endAuction = startAuction + 40320;
        ipfsHash = "";
        bidIncrement = 100;
    }

    modifier notOwner(){
            require(msg.sender != owner);
            _;
    }   

    modifier afterStart(){
        require(block.number >= startAuction);
        _;
    }

    modifier beforeEnd(){
        require(block.number <= endAuction);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    function minBid(uint a, uint b) pure internal returns(uint){
        if(a <= b) {
            return a;
        }else{
            return b;
        }
    }


    function cancelAuction() public onlyOwner {
        auctionStatus = State.Canceled;
    }

    function placeBid() public payable notOwner afterStart beforeEnd {
        require(auctionStatus == State.Running);
        require(msg.value >= 100);

        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid);

        bids[msg.sender] = currentBid;

        if(currentBid <= bids[highestBidder]){
            highestBindingBid = minBid(currentBid + bidIncrement, bids[highestBidder]);
        }else{
            highestBindingBid = minBid(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }

    }

    function finalizeAuction() public {
        require(auctionStatus == State.Canceled || block.number > endAuction);
        require(msg.sender == owner || bids[msg.sender] > 0);

        address payable recipient;
        uint value;

        if(auctionStatus == State.Canceled){
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        }else{
            if(msg.sender == owner){
                recipient = owner;
                value = highestBindingBid;
            }else{
                if(msg.sender == highestBidder){
                    recipient = highestBidder;
                    value = bids[highestBidder] - highestBindingBid;
                }else {
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }
        recipient.transfer(value);
    }
}