var Auction = artifacts.require("Auction");
var Verifier = artifacts.require("Verifier");
//Arguments of the constructor of the Smart Contract
var auctionStartingDate = 1562028269;
var auctionEndingDate = 1593808109;
var minBid = 5;
var idAuction = 1;
var beneficiary = '0x91C10A16C383291B84CA648863f7029387c4d831';
var auctioneer = '0x8f866d67cFFeAEa27a63E3e955D537F7Ea5DF494';
var numberOfBidders = 4;


module.exports = function(deployer, network) {
  // Use deployer to state migration tasks.
  deployer.deploy(Verifier).then(function(){
    return deployer.deploy(Auction, auctionStartingDate, auctionEndingDate, minBid, idAuction, numberOfBidders, beneficiary, auctioneer, Verifier.address)
  });
};