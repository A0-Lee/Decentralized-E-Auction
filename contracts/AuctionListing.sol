// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Auction.sol";

contract AuctionListing {
    // Hold all auction objects
    Auction[] public listedAuctions;

    event AuctionCreated(address owner, uint256 totalAuctions);

    function createAuction(
        uint256 _biddingTime,
        uint256 _startingBid,
        uint256 _bidIncrement,
        uint256 _sellingPrice,
        bool _isPrivate,
        string memory _name,
        string memory _condition,
        string memory _description,
        string memory _ipfsImageHash
    ) public {
        Auction createdAuction = new Auction(
            msg.sender,
            _biddingTime,
            _startingBid,
            _bidIncrement,
            _sellingPrice,
            _isPrivate,
            _name,
            _condition,
            _description,
            _ipfsImageHash    
        );

        listedAuctions.push(createdAuction);
        emit AuctionCreated(msg.sender, listedAuctions.length);
    }

    function getListedAuctions() public view returns (Auction[] memory) {
        return listedAuctions;
    }

    function getOwner(uint _i) public view returns (address) {
        return listedAuctions[_i].owner();
    }

    function getStartBlockTimeStamp(uint _i) public view returns (uint256) {
        return listedAuctions[_i].startBlockTimeStamp();
    }

    function getEndBlockTimeStamp(uint _i) public view returns (uint256) {
        return listedAuctions[_i].endBlockTimeStamp();
    }

    function getAuctionedItem(uint _i) public view returns (string memory, string memory, string memory, string memory) {
        return listedAuctions[_i].auctionedItem();
    }

    function getHighestBidder(uint _i) public view returns (address) {
        return listedAuctions[_i].highestBidder();
    }

    function getHighestBid(uint _i) public view returns (uint256) {
        return listedAuctions[_i].highestBid();
    }

    function getAuctionStatus(uint _i) public view returns (Auction.STATE) {
        return listedAuctions[_i].auctionStatus();
    }

    function getStartingBid(uint _i) public view returns (uint256) {
        return listedAuctions[_i].startingBid();
    }

    function getBidIncrement(uint _i) public view returns (uint256) {
        return listedAuctions[_i].bidIncrement();
    }

    function getSellingPrice(uint _i) public view returns (uint256) {
        return listedAuctions[_i].sellingPrice();
    }

    function getIsPrivate(uint _i) public view returns (bool) {
        return listedAuctions[_i].isPrivate();
    }

    function placeBid(uint _i) public payable returns (bool) {
        return listedAuctions[_i].placeBid{value:msg.value}(msg.sender);
    }

     function withdrawBid(uint _i) public returns (bool) {
        return listedAuctions[_i].withdrawBid(msg.sender);
    }

    function claimBid(uint _i) public payable returns (bool) {
        return listedAuctions[_i].claimBid(msg.sender);
    }

    function cancelAuction(uint _i) public returns (Auction.STATE) {
        return listedAuctions[_i].cancelAuction(msg.sender);
    }

    function endAuction(uint _i) public returns (Auction.STATE) {
        return listedAuctions[_i].endAuction();
    }

     function getUserTotalBids(uint _i, address _bidder) public view returns (uint256) {
        return listedAuctions[_i].trackAllBids(_bidder);
    }

    function getTotalNumberOfBids(uint _i) public view returns (uint256) {
        return listedAuctions[_i].numberOfTotalBids();
    }
}