pragma solidity 0.8.0;

import "./ERC721Token.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract NFT is ERC721Token {
    using SafeMath for uint;

    string public name;
    string public symbol;
    uint256 public tokenCount;

    mapping(uint256 => string) tokenURIs;

    constructor(string memory _name, string memory _symbol) public {
        name = _name;
        symbol = _symbol;
    }

    function tokenUri(uint256 _tokenId) public view returns (string memory) {
        require(owners[_tokenId] != address(0), "TokenId does not exist");
        return tokenURIs[_tokenId];
    }

    function mint(string memory _tokenUri) public {
        tokenCount = tokenCount.add(1);
        balances[msg.sender] = balances[msg.sender].add(1);
        owners[tokenCount] = msg.sender;
        tokenURIs[tokenCount] = _tokenUri;
        emit Transfer(address(0), msg.sender, tokenCount);
    }
}