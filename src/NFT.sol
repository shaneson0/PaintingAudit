// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/utils/Base64.sol";

contract NFT is ERC721URIStorage, Ownable {
    uint256 public tokenId;
    string private imageURI;
    mapping(uint256 => int256) private s_tokenIdToHighValues;

    constructor() ERC721("Painting Together or not", "A Co-painting project with SeeDao members") {
        tokenId = 2;
    }
    function approveNFT(address to, uint256 tokenId) external {
        //require(tokenId == 1);
        // _transfer(from, to, tokenId);
        _approve(to, tokenId);
    }

    function safeMint(address to, string memory uri) public onlyOwner returns(uint256){
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        tokenId = tokenId + 1;
        return tokenId;
        
    }


    function safefinalMint(address to) public onlyOwner{
        _safeMint(to, 1);
       _setTokenURI(1, finalencode()); 
    }

    function setfinalTokenURI() public onlyOwner {
        _setTokenURI(1, finalencode());
    }

    function exchangeMint (uint256 tokenId, string memory uri) public onlyOwner{
        _setTokenURI(tokenId, uri);
    }

    function uploadfinaluri(string memory final_uri) public{
        imageURI = final_uri;
    }

    function finalencode() public view returns(string memory){
        return(
                string(
                    abi.encodePacked( 
                        "data:application/json;base64,",
                        Base64.encode(
                            bytes(
                                abi.encodePacked(
                                    '{"name":"',
                                    name(), // You can add whatever name here
                                    '", "description":"A Co-painting project with SeeDao members. It is the dynamic canvas. R1 = #d24430; R2 = #da6959; R3 = #e58c84; R4 = #ebb4ad; R5 = #f5d9d6; B1 = #4574e6; B2 = #688fea; B3 = #8da9f2; B4 = #b3c3f4; B5 = #d4ddfa", ',
                                    '"attributes": [{"trait_type": "final artwork", "value": 1}], "image":"',
                                    imageURI,
                                    '"}'
                                )
                            )
                        )
                    )
                ));
    }


    /*function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }*/

}
