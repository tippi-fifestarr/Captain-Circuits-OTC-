// SPDX-License-Identifier: MIT
// contracts/NoteBoxFactory.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NoteBoxFactory is ERC721, VRFConsumerBase, Ownable {
    using SafeMath for uint256;
    using Strings for string;

    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    address public VRFCoordinator;
    // rinkeby: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
    address public LinkToken;
    // rinkeby: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709a

    struct NoteBox {
        uint256 strength;
        uint256 dexterity;
        uint256 constitution;
        uint256 intelligence;
        uint256 wisdom;
        uint256 charisma;
        uint256 experience;
        string name;
    }

    NoteBox[] public noteBoxes;

    mapping(bytes32 => string) requestToNoteBoxName;
    mapping(bytes32 => address) requestToSender;
    mapping(bytes32 => uint256) requestToTokenId;

     /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Rinkeby
     * Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK token address:                0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */
    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash)
        public
        VRFConsumerBase(_VRFCoordinator, _LinkToken)
        ERC721("NoteBoxFactory", "D&D")
    {   
        VRFCoordinator = _VRFCoordinator;
        LinkToken = _LinkToken;
        keyHash = _keyhash;
        fee = 0.1 * 10**18; // 0.1 LINK
    }

    function requestNewRandomNoteBox(
        uint256 userProvidedSeed,
        string memory name
    ) public returns (bytes32) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        bytes32 requestId = requestRandomness(keyHash, fee, userProvidedSeed);
        requestToNoteBoxName[requestId] = name;
        requestToSender[requestId] = msg.sender;
        return requestId;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        return tokenURI(tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        uint256 newId = noteBoxes.length;
        uint256 strength = (randomNumber % 100);
        uint256 dexterity = ((randomNumber % 10000) / 100 );
        uint256 constitution = ((randomNumber % 1000000) / 10000 );
        uint256 intelligence = ((randomNumber % 100000000) / 1000000 );
        uint256 wisdom = ((randomNumber % 10000000000) / 100000000 );
        uint256 charisma = ((randomNumber % 1000000000000) / 10000000000);
        uint256 experience = 0;

        noteBoxes.push(
            NoteBox(
                strength,
                dexterity,
                constitution,
                intelligence,
                wisdom,
                charisma,
                experience,
                requestToNoteBoxName[requestId]
            )
        );
        _safeMint(requestToSender[requestId], newId);
    }

    function getLevel(uint256 tokenId) public view returns (uint256) {
        return sqrt(noteBoxes[tokenId].experience);
    }

    function getNumberOfNoteBoxes() public view returns (uint256) {
        return noteBoxes.length; 
    }

    function getNoteBoxOverView(uint256 tokenId)
        public
        view
        returns (
            string memory,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            noteBoxes[tokenId].name,
            noteBoxes[tokenId].strength + noteBoxes[tokenId].dexterity + noteBoxes[tokenId].constitution + noteBoxes[tokenId].intelligence + noteBoxes[tokenId].wisdom + noteBoxes[tokenId].charisma,
            getLevel(tokenId),
            noteBoxes[tokenId].experience
        );
    }

    function getNoteBoxStats(uint256 tokenId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            noteBoxes[tokenId].strength,
            noteBoxes[tokenId].dexterity,
            noteBoxes[tokenId].constitution,
            noteBoxes[tokenId].intelligence,
            noteBoxes[tokenId].wisdom,
            noteBoxes[tokenId].charisma,
            noteBoxes[tokenId].experience
        );
    }

    function sqrt(uint256 x) internal view returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}


// pragma solidity ^0.6.6;

// import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

// contract RandomNumberConsumer is VRFConsumerBase {
    
//     bytes32 internal keyHash;
//     uint256 internal fee;
//     uint256 public randomResult;
//     event RequestedRandomness(bytes32 requestId);
    
//     /**
//      * Constructor inherits VRFConsumerBase
//      * 
//      * Network: Kovan
//      * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
//      * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
//      * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
//      */
//     constructor(address _linkTokenAddress, bytes32 _keyHash, 
//     address _vrfCoordinatorAddress, uint256 _fee)
//         public
//         VRFConsumerBase(
//             _vrfCoordinatorAddress, // VRF Coordinator
//             _linkTokenAddress  // LINK Token
//         )
//     {
//         keyHash = _keyHash;
//         fee = _fee;
//     }
    
//     /** 
//      * Requests randomness from a user-provided seed
//      */
//     function getRandomNumber(uint256 userProvidedSeed) public returns (bytes32 requestId) {
//         requestId = requestRandomness(keyHash, fee, userProvidedSeed);
//         emit RequestedRandomness(requestId);
//     }

//     /** 
//      * Requests the address of the Chainlink Token on this network 
//      */
//     function getChainlinkToken() public view returns (address) {
//         return address(LINK);
//     }

//     /**
//      * Callback function used by VRF Coordinator
//      */
//     function fulfillRandomness(bytes32 /* requestId */, uint256 randomness) internal override {
//         randomResult = randomness;
//     }
// }
