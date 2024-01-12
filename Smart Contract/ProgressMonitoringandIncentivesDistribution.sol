// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

    interface IIncentivesNFT{
        function mint(string memory _ipfshash) external returns(uint);
        function transferFrom(address from, address to, uint256 tokenId) external;
        function ownerOf(uint256 tokenId) external view returns (address owner);
        function tokenCount() external view returns(uint);
    }

    interface IRegistration{
        function regulator() external view returns(address);
        function RegisteredUsers(address) external view returns(bool);
        function RegisteredProgressOracles(address) external view returns(bool);
    }


contract Progress is ReentrancyGuard, IERC721Receiver{

    //Variables//

    IIncentivesNFT private IncentiveNFTSC;
    IRegistration private Registration;
    uint256 public currentIndex = 1; //This counter keeps track of the latest claimable NFT by users
    uint256 public availableNFTs; //Keeps track of the number of vailable NFTs to claim 
    //uint256 public currentClaimableNFT; //Tracks the token ID of the current claimable NFT

    //A mapping that records the number of claimable NFTs for each user
    mapping (address => uint256) public claimableINFTs;
    

    //Events//
    event IncentiveNFTMinted(address indexed regulator, uint256 _tokenId, uint256 _availableNFTs);
    event ProgressUpdated(address indexed _oracle, address indexed _user, uint256 _claimableNFTs, uint256 _completiontime);
    event INFTClaimed(address indexed _user, uint256 _tokenId);
    //Modifiers//

    modifier onlyRegulator(){
        require(msg.sender == Registration.regulator(), "Only the regulator can run this function");
        _;
    }

    modifier onlyRegisteredUser(){
        require(Registration.RegisteredUsers(msg.sender), "Only registered users can run this function");
        _;
    }

    modifier onlyprogressOracle(){
        require(Registration.RegisteredProgressOracles(msg.sender), "Only registered oracles can run this function");
        _;
    }

    
    constructor(address _IncentiveNFTSC, address _registrationSC){
        IncentiveNFTSC = IIncentivesNFT(_IncentiveNFTSC);
        Registration = IRegistration(_registrationSC);
    }

    //Functions//


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
    function mintIncentiveNFTs(string memory _ipfshash) public onlyRegulator nonReentrant{
        
        (uint _tokenId) = IncentiveNFTSC.mint(_ipfshash);
        availableNFTs += 1;

        emit IncentiveNFTMinted(msg.sender, _tokenId, availableNFTs);
 
    }


    //Note: This part can be further improved by adding different NFTs for each game level, but for simplicity it is assumed all levels use the same NFT
    function recordProgress(address _user) public onlyprogressOracle{
        claimableINFTs[_user] += 1; 
        emit ProgressUpdated(msg.sender, _user, claimableINFTs[_user], block.timestamp);
    }

    function claimNFT() public onlyRegisteredUser{
        uint256 nftToClaim = currentIndex;
        require(claimableINFTs[msg.sender] >= 1, "This user doesn't have sufficient NFT balance");
        require(availableNFTs >= 1, "This contract doesn't have any NFTs to claim, please wait for refill");
        require(nftToClaim > 0 && nftToClaim <= IncentiveNFTSC.tokenCount(), "The current index is invalid"); //Probably not needed
        IncentiveNFTSC.transferFrom(address(this), msg.sender, nftToClaim);
        claimableINFTs[msg.sender] -= 1;
        availableNFTs -= 1;
        currentIndex += 1;

        emit INFTClaimed(msg.sender, nftToClaim);
    }    

}

