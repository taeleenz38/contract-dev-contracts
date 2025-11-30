// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract ContractDevNFT {
    string public name;
    string public symbol;
    address public owner;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;
    
    // Mapping from owner address to token count
    mapping(address => uint256) private _balances;
    
    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;
    
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    uint256 private _nextTokenId = 1;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    event Mint(address indexed to, uint256 indexed tokenId);

    constructor() {
        name = "ContractDev NFT";
        symbol = "CDNFT";
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function totalSupply() public view returns (uint256) {
        return _nextTokenId - 1;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        require(
            _owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address tokenOwner = _owners[_tokenId];
        require(
            tokenOwner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return tokenOwner;
    }

    function approve(address _to, uint256 _tokenId) public {
        address tokenOwner = ownerOf(_tokenId);
        require(_to != tokenOwner, "ERC721: approval to current owner");
        require(
            msg.sender == tokenOwner ||
                isApprovedForAll(tokenOwner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[_tokenId] = _to;
        emit Approval(tokenOwner, _to, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        require(
            _owners[_tokenId] != address(0),
            "ERC721: approved query for nonexistent token"
        );
        return _tokenApprovals[_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        require(_operator != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(
        address _owner,
        address _operator
    ) public view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, _tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        require(_to != address(0), "ERC721: transfer to the zero address");

        _transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, _tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        require(_to != address(0), "ERC721: transfer to the zero address");

        _transfer(_from, _to, _tokenId);
        // Basic check that recipient can handle ERC721 tokens
        require(
            _checkOnERC721Received(_from, _to, _tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function mint(address _to) public onlyOwner returns (uint256) {
        require(_to != address(0), "ERC721: mint to the zero address");

        uint256 tokenId = _nextTokenId;
        _nextTokenId++;

        _balances[_to] += 1;
        _owners[tokenId] = _to;

        emit Transfer(address(0), _to, tokenId);
        emit Mint(_to, tokenId);

        return tokenId;
    }

    function burn(uint256 _tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, _tokenId),
            "ERC721: burn caller is not owner nor approved"
        );

        address tokenOwner = ownerOf(_tokenId);
        _balances[tokenOwner] -= 1;
        delete _owners[_tokenId];
        delete _tokenApprovals[_tokenId];

        emit Transfer(tokenOwner, address(0), _tokenId);
    }

    function updateOwner(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0),
            "New owner cannot be the zero address"
        );
        owner = _newOwner;
    }

    // Internal functions

    function _isApprovedOrOwner(
        address _spender,
        uint256 _tokenId
    ) internal view returns (bool) {
        address tokenOwner = ownerOf(_tokenId);
        return (_spender == tokenOwner ||
            getApproved(_tokenId) == _spender ||
            isApprovedForAll(tokenOwner, _spender));
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        require(
            ownerOf(_tokenId) == _from,
            "ERC721: transfer from incorrect owner"
        );
        require(_to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        delete _tokenApprovals[_tokenId];

        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function _checkOnERC721Received(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) internal returns (bool) {
        // Basic implementation - in production, you'd check if _to implements IERC721Receiver
        // For simplicity, we'll just return true here
        // A full implementation would check:
        // if (_to.code.length > 0) {
        //     try IERC721Receiver(_to).onERC721Received(...) returns (bytes4 retval) {
        //         return retval == IERC721Receiver.onERC721Received.selector;
        //     } catch {
        //         return false;
        //     }
        // }
        return true;
    }
}

