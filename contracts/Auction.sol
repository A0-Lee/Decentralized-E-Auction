// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Auction {
    // State variables, uint256 = unsigned integer of 256 bits, address = Ethereum account addresses (20 bytes)

    // Store's the auction owner = contract owner
    address public owner;
    // Auction start and end times (since unix epoch in seconds)
    uint256 public startBlockTimeStamp;
    uint256 public endBlockTimeStamp;
    // Highest bid in Ether
    uint256 public highestBid;
    // Address of current highest bidder
    address public highestBidder;
    // Minimum starting bid
    uint256 public startingBid;
    // Bid increment/step
    uint256 public bidIncrement;
    // Buyout/Selling price
    uint256 public sellingPrice;
    // Auction Type (Public or Private)
    bool public isPrivate;
    // Track number of total bids
    uint256 public numberOfTotalBids = 0;


    // Auction states
    enum STATE {
        CANCELLED,
        ONGOING,
        ENDED
    }

    STATE public auctionStatus;

    // structure is a collection of variables using different data types
    // we define an Item structure for the auctioned item
    struct Item {
        string name;
        string condition;
        string description;
        string ipfsImageHash;
    }

    Item public auctionedItem;

    constructor(
        address _owner,
        uint256 _biddingTime,
        uint256 _startingBid,
        uint256 _bidIncrement,
        uint256 _sellingPrice,
        bool _isPrivate,
        string memory _name,
        string memory _condition,
        string memory _description,
        string memory _ipfsImageHash
    ) {
        owner = _owner;
        startBlockTimeStamp = block.timestamp;
        // time is in hours
        endBlockTimeStamp = startBlockTimeStamp + (_biddingTime * 1 hours);
        auctionStatus = STATE.ONGOING;
        startingBid = _startingBid;
        bidIncrement = _bidIncrement;
        sellingPrice = _sellingPrice;
        isPrivate = _isPrivate;
        auctionedItem.name = _name;
        auctionedItem.condition = _condition;
        auctionedItem.description = _description;
        auctionedItem.ipfsImageHash = _ipfsImageHash;
    }

    // dynamic array of all bidder's addresses
    address[] bidders;
    // bids - maps all bidders with their total bids, hash map (KeyType => ValueType)
    // variables with the public modifier have automatic getters
    mapping(address => uint256) public trackAllBids;

    // makes the contract ownable - giving contract owner specific priviledges
    modifier only_owner(address _user) {
        // require will refund the remaining gas to the caller
        require(_user == owner, "Must be the Auction contract owner.");
        _;
    }

    modifier is_ongoing() {
        require(auctionStatus == STATE.ONGOING, "Auction status must be ONGOING.");
        _;
    }

    modifier is_expired() {
        require(auctionStatus != STATE.ONGOING, "Auction status must be EXPIRED (CANCELLED OR ENDED).");
        _;
    }

    function placeBid(address _bidder)
        public
        payable
        is_ongoing
        returns (bool)
    {
        
        if (bidIncrement > 0 ) {
            require(msg.value >= highestBid + bidIncrement, "Placed bid must be greater than highest bid + bid increment.");
        } else {
            require(msg.value > highestBid, "Placed bid must be greater than highest bid.");
        }

        if (startingBid > 0 ) {
            require(msg.value >= startingBid, "Initial bid must be greater or equal to starting bid.");
        }
        
        numberOfTotalBids++;
        highestBidder = _bidder;
        // msg.value is the bid value in wei
        highestBid = msg.value;
        bidders.push(highestBidder);

        if (trackAllBids[_bidder] > 0) {
            payable(_bidder).transfer(trackAllBids[_bidder]);
            trackAllBids[_bidder] = 0;
        }

        trackAllBids[highestBidder] = trackAllBids[highestBidder] + msg.value;

        emit bidEvent(highestBidder, highestBid);

        return true;
    }

    function withdrawBid(address _bidder) public is_expired returns (bool) {
        require(trackAllBids[_bidder] > 0, "You've already withdrawn from this auction.");
        uint256 amount;

        // Find bid placed by address of bidder (hash map)
        amount = trackAllBids[_bidder];
        // Set current bid by withdrawer to 0 (update hash map)
        trackAllBids[_bidder] = 0;
        // Transfer back funds
        payable(_bidder).transfer(amount);
        // Trigger event
        emit withdrawalEvent(_bidder, amount);

        return true;
    }

    function claimBid(address _owner)
        public
        only_owner(_owner)
        is_expired
        returns (bool)
    {
        require(trackAllBids[highestBidder] > 0, "Highest bidder must have a bid greater than 0 ETH to claim.");
        uint256 winningAmount;

        winningAmount = trackAllBids[highestBidder];
        trackAllBids[highestBidder] = 0;

        payable(_owner).transfer(winningAmount);
        emit claimEvent(_owner, winningAmount);

        return true;
    }

    function cancelAuction(address _owner)
        public
        only_owner(_owner)
        is_ongoing
        returns (STATE)
    {
        require(auctionStatus != STATE.ENDED, "Cannot cancel an Auction that has ended.");
        auctionStatus = STATE.CANCELLED;
        emit statusEvent("Auction state is cancelled.", block.timestamp);

        return auctionStatus;
    }

    function endAuction() public is_ongoing returns (STATE) {
        auctionStatus = STATE.ENDED;
        emit statusEvent("Auction state is ended.", block.timestamp);

        return auctionStatus;
    }

    event bidEvent(address indexed highestBidder, uint256 highestBid);
    event withdrawalEvent(address withdrawer, uint256 amount);
    event claimEvent(address owner, uint256 highestBid);
    event statusEvent(string message, uint256 time);
}
