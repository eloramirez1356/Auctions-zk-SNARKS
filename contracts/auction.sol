pragma solidity >=0.4.22 < 0.6.0;
import "./verifier.sol";
contract Auction{
    //Verifier Contract
    Verifier public verifierContractZoKrates;
    
    //Variables needed for the auction
    uint public auctionStartingDate; //Variable que indica el momento inicial en el que se permiten pujas
    uint public auctionEndingDate; //Variable que indica el momento final en el que ya no se admiten pujas
    uint public provingBidsStartingDate;//Variable que indica el momento en el que se permiten cotejar pujas
    uint public provingBidsEndingDate;//Variable que indica el momento final para cotejar pujas
    uint public minBid; //Signal for bidding
    uint public idAuction; //Id de la subasta
    uint public numberOfBidders; //Numero fijo de participantes en la subasta
    address payable public beneficiary; //Beneficiario del objeto subastado
    address public auctioneer; //Address del auctioneer
    address public winner; //Address del Winner
    bool public auctionEnded; //Variable que indica si la subasta ha finalizado
    //address payable public verifierContractAddress;
    
    //Array que contiene las apuestas + salts
    mapping(string => address payable) bidsAddresses; //Mapping con el que obtienes las direcciones de las codificaciones
    bytes32[] public bids; //array que contiene las apuestas hasheadas
    string[] public bidAmounts; //Array que contiene las cantidades encryptadas con la clave publica pero sin hash
    string[2][] public hashZokratesBids; //Array que contiene los hashes de la apuesta obtenidos con Zokrates
    uint public biggestBid;
    uint public positionWinnerBid;



    constructor(uint _auctionStartingDate, uint _auctionEndingDate, uint _minBid, uint _idAuction, uint _numberOfBidders, address payable _beneficiary, address payable _auctioneer,address payable _verifierContractAddress) public {
        //Determinamos todos estos datos al crear el contrato
        auctionStartingDate = _auctionStartingDate; //Inicio de la fecha para apostar
        auctionEndingDate = _auctionEndingDate; //Fin de la fecha para apostar
        provingBidsStartingDate = _auctionStartingDate + 600; //600 son 10 mins despues de la fecha establecida
        provingBidsEndingDate = _auctionEndingDate + 600;
        minBid = _minBid * 1e18; //Apuesta minima
        idAuction = _idAuction; //Id of the auction
        beneficiary = _beneficiary; //Beneficiary of the auction
        auctioneer = _auctioneer; //Auctioneer
        numberOfBidders = _numberOfBidders; //Number of bidders
        verifierContractZoKrates = Verifier(_verifierContractAddress);//Initialization of the verifier contract
        //bids = new bytes32[](numberOfBidders); //array que contiene las apuestas hasheadas
        //bidAmounts = new string[](numberOfBidders); //Array que contiene las cantidades encryptadas con la clave publica pero sin hash
        //hashZokratesBids = new string[2][](numberOfBidders); //Array que contiene los hashes de la apuesta obtenidos con Zokrates
    }

    //Realizacion de la puja en el intervalo de la subasta
    //Tiene que poner que solo un usuario, que todos los valores de los hashes sean diferentes
    //En el javascript se pueden concatenar facilmente los numeros de Zokrates, y se mete como hashedEncryptedBid, donde se introducen juntos (out1, out2), y además un salt
    //OJO, para comprobar la minima apuesta, hacerlo con el javascript porque en este caso no interesa meter el valor a pelo.
    //Poner la restriccion de numero de bidders
    function bid(bytes32 hashedEncryptedBid) public payable{
        require(msg.sender != auctioneer, "Auctioneer cant bid");
        require(now >= auctionStartingDate && now <= auctionEndingDate, "You only can bid during the bidding period");
        require(msg.value==minBid, "You have to pay signal for bidding");
        //require(bids[numberOfBidders-1] != "0x0", "All the possible bids has been done, no more bids can be done");
        bids.push(hashedEncryptedBid);
    }
    
    //Funcion para encriptar la apuesta cifrada con la clave publica y el hash obtenido con zokrates. Esta funcion se usa en bidprover
    function keccak256Hash(string memory encrypted, string memory hashZokrates1, string memory hashZokrates2) public pure returns (bytes32 hashSolidity){
        return keccak256(abi.encode(bytes(encrypted), bytes(hashZokrates1), bytes(hashZokrates2)));
    }

    //Funcion que compara el hash inicial que contiene la apuesta encriptada con la clave publica y los hashes emitidos con zokrates
    function bidProver(bytes32 bidHashedSent, string memory encryptedBid, string memory hashZokrates1, string memory hashZokrates2) public payable{
        //Tengo que meterle la restriccion del segundo periodo, despues de que no se permitan mas pujas
        //require(now >= provingBidsStartingDate && now <= provingBidsStartingDate, "You only can prove that you have bid during the proving period, after bidding period");
        //require(bids[numberOfBidders-1] != "0x0", "All the bids have been proved");
        
        for (uint i=0; i<bids.length; i++) {
            if (bids[i] == bidHashedSent) {
                //Si los hashes de cada elemento del primer array coinciden con l
                
                require(bidHashedSent == keccak256Hash(encryptedBid, hashZokrates1, hashZokrates2), "The hashed bid sent does not correspond to hash of the values you are providing");
                //This user knows the information sent, then execute the transaction of the other Contract
                //bool result = verifierContractZoKrates.verifyTx(a, b, c, input);
                //Capture event from this verifyTx call: If success, add the values of the response or the values entered into array for checking which is the biggest one, return the money and receive all the amount from the winner
                //Capturamos este evento en el Javascript. Si devuelve true, ejecutamos la funcion de que introduce la puja para la subasta.
                
                    //lo que quiero hacer ahora es crear un nuevo uint que una los 4 valores de la puja, para obtener un uint que sea unico.
                    //uint bidAfterProof = input[0] * 1000 + input[1] *100 + input[2] *10 + input[3];
                //Rellenas el array de apuestas encriptadas con clave publica
                
                bidAmounts.push(encryptedBid);
                //Rellenas el array de hashes de zokrates
                hashZokratesBids.push([hashZokrates1, hashZokrates2]);
                
                //Introduzco la direccion y la relaciono con la apuesta encriptada con la clave publica
                bidsAddresses[encryptedBid] = msg.sender;
                delete bids[i];
                break;
            }
        }  
    }
    
    //Funcion donde el auctioneer aporta su prueba y muestra el ganador. El resultado se tiene que obtener en el javascript y se debe ejecutar posteriormente,
    //En esta funcion hay que jugar con el javascript, obtener el return que devuelve y lanzar una funcion con estos valores
    event resultPosition(uint256 positionEvent);
    event resultWinner(uint256 winnerEvent);
    function auctionEnd(uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[14] memory input) public payable returns (uint position, uint highestBid){
        //Poner un require de que solo entre el auctioner
        //require(now >= provingBidsEndingDate, "The auction has not ended");
        //require(auctionEnded == false, "The auction has ended");
        //require(winner == address(0), "There is already a winner");
        //Getting the winner
        //ITERAR AHORA SOBRE EL ARRAY DE BIDS Y OBTENER EL MAXIMO, Y SACAR LA ADDRESS.
        //Hacerlo luego con la modificacion de las variables e implementar zk-snarks.

        //Compruebo si la solucion proporcionada por el auctioneer es correcta o no.
        bool result = verifierContractZoKrates.verifyTx(a, b, c, input);
        require(result, "Incorrect proof");
        emit resultPosition(input[12]);
        emit resultWinner(input[13]);
        biggestBid = input[13];
        positionWinnerBid = input[12];
        
        for (uint i = 0; i < bidAmounts.length; i++){
            bidsAddresses[getBidAmounts(i)].transfer(minBid);
        }
        return (input[12], input[13]);
        //winner = bidsAddresses[largest];
    }

    //Esta funcion es para ver que realmente funciona la devolucion de ethers, pero se ejecuta dentro de auction end
    function returnSignals() public payable{
        //Return money with these lines
        for (uint i = 0; i < bidAmounts.length; i++){
            bidsAddresses[getBidAmounts(i)].transfer(minBid);
        }
    }

    //Esta operacion solo puede ejecutarla el winner
    function paymentOperations() public payable{
        require(msg.sender == bidsAddresses[bidAmounts[positionWinnerBid]], "You are trying to call this function but you are not the winner");
        //Si llama otro, dará error. Puede servir para comprobar si eres ganador o no.
        require(msg.value == biggestBid, "You have to pay the bid you promised for obtaining your profits");
        require(auctionEnded == false, "The auction has already ended and the profits are being sent");
        //Payment to the beneficiary

        beneficiary.transfer(msg.value);
        //bidsAddresses[bidAmounts[position]].transfer(highestBid);
        //Return of payment for people who has paid money for bidding
        //delete bidAmounts[position];
        //Return money paid by all the bidders
        /*for (uint i = 0; i < bidAmounts.length; i++){
            bidsAddresses[bidAmounts[i]].transfer(minBid);
        }
        delete bidAmounts;*/
        auctionEnded = true;

    }

    /*function returnPayments() public payable{
        //Return money paid by all the bidders
        for (uint i = 0; i < bidAmounts.length; i++){
            bidsAddresses[bidAmounts[i]].transfer(minBid);
        }
        delete bidAmounts;

    }*/

    function getBids(uint i) public returns(bytes32 position){
        return bids[i];
    }

    function getBidAmounts(uint i) public returns(string memory encryptedAmount){
        return bidAmounts[i];
    }

    function getHashesZokrates(uint i) public returns(string memory hashZok1, string memory hashZok2){
        return (hashZokratesBids[i][0], hashZokratesBids[i][1]);
    }
    
    function getBiggestBid() public returns (uint winnerBid){
        return biggestBid;
    }

    //Ahora con estos números, tras acabar la subasta, el usuario tiene que demostrar que realmente es él, introduciendo los valores fuera del hash.
    //Con otro intervalo de tiempo, para que todo el mundo meta lo que ha apostado (demuestre)
    //Una vez demostrado, el auctioneer ejecuta la prueba con los valores introducidos en Zokrates con el contrato generado, y si funciona correctamente, el valor devuelto de su apuesta aparece encriptado con la privada
    //Tras finalizar la subasta, se tiene que permitir subir el cifrado con la secret, el cual se puede descifrar con la public de este Smart Contract
    //Ahora toca subir el cifrado con la Sk, tras haber conseguido obtener este valor con Zokrates

}