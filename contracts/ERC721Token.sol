pragma solidity 0.8.0;

import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract ERC721Token {
    using SafeMath for uint;

    mapping(address => uint256) internal balances;
    mapping(uint256 => address) internal owners;
    mapping(address => mapping(address => bool)) private operatorApprovals;
    mapping(uint256 => address) internal tokenApprovals;

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool approved);
    event Approval(address indexed _owner, address indexed _to, uint256 _tokenId);
    event Transfer(address indexed _from , address indexed _to, uint256 _tokenId);

    // Number of NFTs assigned to an owner/address
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "Address of zero account");
        return balances[_owner];
    }

    // Find owner of an NFT
    function ownerOf(uint256 _ownerId) public view returns (address) {
        address _owner = owners[_ownerId];
        require(_owner != address(0), "Address of zero account");
        return _owner;
    }

    // Permits/disables an operator to manage the assets of the owner
    function setApprovalForAll(address _operator, bool _approved) public {
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // Checks if an address is an approved operator for another address
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    // Updates the approved address of a token
    // Checks of the person calling the contract(msg.sender) is the owner of the token or is an approved operator of the token.
    function approve(address _to, uint256 _tokenId) public {
        address _owner = ownerOf(_tokenId);
        require((_owner == msg.sender || isApprovedForAll(_owner, msg.sender)), "Not the owner or an approved operator of the token");
        tokenApprovals[_tokenId] = _to;
        emit Approval(_owner, _to, _tokenId);
    }

    // Returns the approved address of a NFT token
    function getApproved(uint256 _tokenId) public view returns (address) {
        require(owners[_tokenId] != address(0), "Not a valid token id");
        return tokenApprovals[_tokenId];
    }

    // Tranfer from one address to another
    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        address _owner = ownerOf(_tokenId);
        require((_owner == msg.sender ||
                getApproved(_tokenId) == msg.sender ||
                isApprovedForAll(_owner, msg.sender)), "msg.sender is not the owner or approved to transfer");
        require(_owner == _from, "From address id not the owner of the NFT");
        require(_to != address(0), "To address is zero address");
        require(owners[_tokenId] != address(0), "Not a valid token id");
        approve(address(0), _tokenId);
        balances[_from] = balances[_from].sub(1);
        balances[_to] = balances[_to].add(1);
        emit Transfer(_from, _to, _tokenId);
    }

}

