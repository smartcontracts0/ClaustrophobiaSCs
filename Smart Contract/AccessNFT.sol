// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol"; //Imported in case burning NFTs is used
import "@openzeppelin/contracts/access/Ownable.sol";

    //This interface is needed so that the regulator can mint an NFT for registered users 
    interface IRegistration{
        //function regulator() external view returns(address);
        //function registerUser(address) external; 
    }

contract AccessNFTs is ERC721URIStorage, Ownable(msg.sender){
    uint public tokenCount;
    IRegistration public Registration;

    constructor () ERC721("Access", "ANFT"){} // The constructor uses the imported ERC721 contract which requires two inputs in its constructor, the name and symbol of the NFT
    

    function setRegistrationSC(address _registrationSC) external onlyOwner{
        Registration = IRegistration(_registrationSC);
    }

    //Optional: Make only authorized users mint Raw Genomics Data NFT
    function mint(string memory _tokenURI, address _user) external returns(uint){
        require(msg.sender == address(Registration), "The caller cannot run this function");
        tokenCount++;
        _safeMint(_user, tokenCount); 
        _setTokenURI(tokenCount, _tokenURI);
        return(tokenCount);
    }

    function burn(uint256 _tokenID) external returns(uint){
        require(msg.sender == address(Registration), "The caller cannot run this function");
        _burn(_tokenID);
        return(_tokenID);
    }





}