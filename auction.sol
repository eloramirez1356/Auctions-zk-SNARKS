pragma solidity >=0.4.22 <0.6.0;
contract Auction{
    uint public auctionBegins;
    uint public auctionStarts;
    uint public minBid;
    uint public idAuction;
    
    struct bidder{
        address public bidderAddress;
        uint public bid;
        uint public bidTime;
    }
    
    bidder[] auctionBidders;
    
    
}