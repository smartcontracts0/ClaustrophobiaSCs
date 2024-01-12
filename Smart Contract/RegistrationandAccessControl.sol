// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; 

//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface IAccessNFT{
    function mint(string memory, address) external returns(uint);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function burn(uint256 tokenId) external returns(uint);
}

contract Registration{


    //Variables//

    IAccessNFT private AccessNFTSC; 
    address public regulator;
    //This mapping is used to register new users 
    mapping(address => bool) public RegisteredUsers;
    mapping(address => bool) public RegisteredProgressOracles;

    //Maps the address of the registered user to their corresponding NFT
    mapping(address => uint256) public userAccessNFT;

    //Events//
    event UserRegistered(address indexed _user, uint256 _tokenid); 
    event ProgressOracleRegistered(address indexed _oracle);
    event UserUnRegistered(address indexed _user);
    event RegulatorAssigned(address indexed _regulator);

    //Modifiers//

    modifier onlyRegulator(){
        require(regulator == msg.sender, "Only the regulator can run this function");
        _;
    }


    constructor(address _AccesSNFTSC){
        regulator = msg.sender;
        AccessNFTSC = IAccessNFT(_AccesSNFTSC);
        emit RegulatorAssigned(msg.sender);
    }

    //Functions//

    function registerUser(address _user, string memory _IPFSHash) public onlyRegulator{
        require(!RegisteredUsers[_user], "This user has already been registered");
        require(_user != regulator, "The role of the regulator cannot be changed");
        RegisteredUsers[_user] = true; 
        (uint _tokenId) = AccessNFTSC.mint(_IPFSHash, _user);
        userAccessNFT[_user] = _tokenId;
        emit UserRegistered(_user, _tokenId);
    }

    function unregisterUser(address _user) public onlyRegulator{
        require(RegisteredUsers[_user], "This user is already not registered");
        RegisteredUsers[_user] = false;
        AccessNFTSC.burn(userAccessNFT[_user]);
        emit UserUnRegistered(_user);
    }

    function registerProgressOracle(address _oracle) public onlyRegulator{
        require(!RegisteredProgressOracles[_oracle], "This oracle is already registered");
        require(_oracle != regulator, "The role of the regulator cannot be changed");
        RegisteredProgressOracles[_oracle] = true;
        emit ProgressOracleRegistered(_oracle);
    }
}
