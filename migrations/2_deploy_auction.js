var Auction = artifacts.require("Auction");
var Verifier = artifacts.require("Verifier");
//Arguments of the constructor of the Smart Contract
var auctionStartingDate = 1562028269;
var auctionEndingDate = 1593808109;
var minBid = 5;
var idAuction = 1;
var beneficiary = '0x8f866d67cFFeAEa27a63E3e955D537F7Ea5DF494';
var auctioneer = '0x5E905cC01f3caFE8DE57df119de0B3f9d66395D2';
var numberOfBidders = 4;


module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(Verifier).then(function(instance){
    return deployer.deploy(Auction, auctionStartingDate, auctionEndingDate, minBid, idAuction, numberOfBidders, beneficiary, auctioneer, Verifier.address)
  });
};