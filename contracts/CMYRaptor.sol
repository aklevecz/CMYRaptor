pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CMYRaptor is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public owner;

    struct CMYK {
        uint8 c;
        uint8 m;
        uint8 y;
        uint8 k;
    }

    mapping(uint256 => CMYK) public tokenColors;

    event RaptorMinted(address indexed _recipient, uint256 _tokenId);

    constructor() public ERC721("CMYRaptor", "CMYR") {
        owner = msg.sender;
        _setBaseURI("ipfs://");
    }

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function checkDupe(
        uint8 _c,
        uint8 _m,
        uint8 _y,
        uint8 _k
    ) public view returns (bool) {
        bool isDupe = false;
        for (uint16 i = 1; i <= _tokenIds.current(); i++) {
            CMYK memory cmyk = tokenColors[i];
            if (cmyk.c == _c && cmyk.m == _m && cmyk.y == _y && cmyk.k == _k) {
                isDupe = true;
            }
        }
        return isDupe;
    }

    function mintRaptor(
        address _recipient,
        uint8 _c,
        uint8 _m,
        uint8 _y,
        uint8 _k,
        string memory _tokenURI
    ) public payable {
        require(msg.value >= 10**16, "must be .01 eth");
        CMYK memory _cmyk = CMYK(_c, _m, _y, _k);
        require(!checkDupe(_c, _m, _y, _k), "no dupes");
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(_recipient, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        tokenColors[newTokenId] = _cmyk;
        emit RaptorMinted(_recipient, newTokenId);
    }

    function withdraw() public restricted {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }
}
