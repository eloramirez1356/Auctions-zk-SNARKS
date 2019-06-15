pragma solidity >=0.4.22 <0.6.0;
contract Auction{
    //Mejor no usarlo porque cuesta y realmente no es necesario, empieza cuando ejecutas el contrato en la blockchain
    //=> Mejor ponerla porque asi lo subes y automaticamente comienza

    uint public auctionStartingDate; //Variable que indica el momento inicial en el que se permiten pujas
    uint public auctionEndingDate; //Variable que indica el momento final en el que ya no se admiten pujas
    uint public minBid; //Puja minima
    uint public idAuction; //Id de la subasta, suponiendo que habra varias
    address public beneficiary; //Beneficiario
    //La idea es obtener la bid mas alta del array y obtener la direccion del mapping...
    //La otra opcion es hacer una variable con puja maxima e ir modificandola o no (creo que es mas eficiente).
    //Puedes hacerlo de las dos maneras y comparar, y ponerlo en el TFM como has ido viendo el coste.
    mapping(uint => address) bidsAddresses;
    uint[] bids;
    //Se podría ahorrar haciendo dos maps, uno de address => bid y otro de address => bidTime
    /*struct bidder{
        address public bidderAddress; //cuenta del pujante
        uint public bid; //Puja del pujante
        uint public bidTime; //Momento en el que se realiza la puja
    }*/
    
    //bidder[] auctionBidders; //Array en el que se introducen todos los pujantes

    //Events of the contract
    //Execution of the auction

    constructor(uint _auctionStartingDate, uint _auctionEndingDate, uint _minBid, uint _idAuction, address _beneficiary) public {
        auctionStarts = _auctionStarts;
        auctionEndingDate = _auctionEndingDate;
        minBid = _minBid;
        idAuction = _idAuction;
        beneficiary = _beneficiary;
    }

    function bid() public payable {
        require(now >= auctionStarts && now <= auctionEndingDate && msg.value >= minBid);

        bidsAddresses[msg.value] = msg.sender;
        bids.push(msg.value);

    }

    function auctionEnd() public {
        require(now >= auctionEndingDate);
        //Getting the winner
        //O h

    }


}