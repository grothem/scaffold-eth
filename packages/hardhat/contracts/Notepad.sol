// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'base64-sol/base64.sol';
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Notepad is ERC1155, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() public ERC1155("") {}

    function mintItem(address _to, uint256 _amount) public returns(uint256) {
        _tokenIds.increment();
        uint256 id = _tokenIds.current();
        _mint(_to, id, _amount, "");

        return id;
    }

    function generateSVGofTokenById(address owner, uint256 tokenId) internal pure returns (string memory) {

        string memory svg = string(abi.encodePacked(
        '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
            '<text x="20" y="35" class="small">',
            Strings.toString(tokenId),
            '</text>',
        '</svg>'
        ));

        return svg;
    }

    function tokenURI(address owner, uint256 tokenId) internal pure returns (string memory) {

        string memory name = string(abi.encodePacked('Example SVG ', Strings.toString(tokenId)));
        string memory image = Base64.encode(bytes(generateSVGofTokenById(owner, tokenId)));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Notepad #',
                        Strings.toString(tokenId),
                        '", "description": "A notepad on the blockchain.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(image)),
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}
