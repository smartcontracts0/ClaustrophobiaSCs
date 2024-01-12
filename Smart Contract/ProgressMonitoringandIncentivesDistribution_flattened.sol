// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.20;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: ProgressMonitoringandIncentivesDistribution.sol


pragma solidity ^0.8.7;



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

