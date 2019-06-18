pragma solidity >=0.4.22 <0.6.0;
contract Auction{
    //Mejor no usarlo porque cuesta y realmente no es necesario, empieza cuando ejecutas el contrato en la blockchain
    //=> Mejor ponerla porque asi lo subes y automaticamente comienza

    uint public auctionStartingDate; //Variable que indica el momento inicial en el que se permiten pujas
    uint public auctionEndingDate; //Variable que indica el momento final en el que ya no se admiten pujas
    uint public minBid; //Puja minima
    uint public idAuction; //Id de la subasta, suponiendo que habra varias
    address payable public beneficiary; //Beneficiario
    address public winner;
    bool public auctionEnded;
    //La idea es obtener la bid mas alta del array y obtener la direccion del mapping...
    //La otra opcion es hacer una variable con puja maxima e ir modificandola o no (creo que es mas eficiente).
    //Puedes hacerlo de las dos maneras y comparar, y ponerlo en el TFM como has ido viendo el coste.
    mapping(uint => address payable) bidsAddresses;
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

    constructor(uint _auctionStartingDate, uint _auctionEndingDate, uint _minBid, uint _idAuction, address payable _beneficiary) public {
        //Determinamos todos estos datos al crear el contrato
        auctionStartingDate = _auctionStartingDate;
        auctionEndingDate = _auctionEndingDate;
        minBid = _minBid * 1e18;
        idAuction = _idAuction;
        beneficiary = _beneficiary;
    }

    function bid() public payable{
        require(now >= auctionStartingDate && now <= auctionEndingDate && msg.value >= minBid);

        bidsAddresses[msg.value] = msg.sender;
        bids.push(msg.value);



    }

    function auctionEnd() public {
        require(now >= auctionEndingDate, "The auction has not ended");
        require(auctionEnded == false, "The auction has ended");
        require(winner == address(0), "There is already a winner");
        //Getting the winner
        //ITERAR AHORA SOBRE EL ARRAY DE BIDS Y OBTENER EL MAXIMO, Y SACAR LA ADDRESS.
        //Hacerlo luego con la modificacion de las variables e implementar zk-snarks.
        uint i;
        uint largest;
        
        for(i = 0; i < bids.length; i++){
            if(bids[i] > largest){
                largest = bids[i];
            }
        }

        winner = bidsAddresses[largest];
        for(i = 0; i < bids.length; i++){
            if(bids[i] < largest){
                bidsAddresses[bids[i]].transfer(bids[i]);
                bids[i] = 0;
            }else{
                beneficiary.transfer(largest);
                bids[i] = 0;
            }
        }
        auctionEnded = true;

    }

    

}