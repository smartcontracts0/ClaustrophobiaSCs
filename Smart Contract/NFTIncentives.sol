// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol"; //Imported in case burning NFTs is used
import "@openzeppelin/contracts/access/Ownable.sol";

    interface IProgress{
        
    }

contract IncentiveNFTs is ERC721URIStorage, Ownable(msg.sender){

    IProgress public Progress;
    uint public tokenCount;
    constructor () ERC721("Incentives", "INFT"){} // The constructor uses the imported ERC721 contract which requires two inputs in its constructor, the name and symbol of the NFT
    

    
    function setProgressSC(address _progressSC) external onlyOwner{
        Progress = IProgress(_progressSC);
    }

    //Optional: Make only authorized users mint Raw Genomics Data NFT
    function mint(string memory _tokenURI) external returns(uint){
        require(msg.sender == address(Progress), "The caller cannot run this function");
        tokenCount++;
        _safeMint(msg.sender, tokenCount); 
        _setTokenURI(tokenCount, _tokenURI);
        return(tokenCount);
    } 

}