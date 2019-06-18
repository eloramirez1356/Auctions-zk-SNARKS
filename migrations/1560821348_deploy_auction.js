var Auction = artifacts.require("Auction");
//Arguments of the constructor of the Smart Contract
var auctionStartingDate = 1560825814;
var auctionEndingDate = 1560841503;
var minBid = 5;
var idAuction = 1;
var beneficiary = '0x1440239959Df7a51111605C7BC470D997c81361a';

module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(Auction, auctionStartingDate, auctionEndingDate, minBid, idAuction, beneficiary);
};
