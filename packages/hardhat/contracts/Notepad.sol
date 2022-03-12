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

    string[] private _note;

    constructor() public ERC1155("") {}

    function mintItem(address _to, uint256 _amount) public returns(uint256) {
        _tokenIds.increment();
        uint256 id = _tokenIds.current();
        _mint(_to, id, _amount, "");

        return id;
    }

    function addToNote(string memory add) public onlyOwner {
        _note.push(add);
    }

    function generateSVGofTokenById(address owner, uint256 tokenId) public view returns (string memory) {
        string memory svg = string(abi.encodePacked(
        '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
            '<text x="20" y="35" class="small">',
                noteAsSVGText(),
            '</text>'
        '</svg>'
        ));

        return svg;
    }

    function tokenURI(address owner, uint256 tokenId) public view returns (string memory) {
        string memory image = Base64.encode(bytes(generateSVGofTokenById(owner, tokenId)));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Notepad #',
                        Strings.toString(tokenId),
                        '", "description": "A notepad on the blockchain.", "image": "data:image/svg+xml;base64,',
                        image,
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function noteAsSVGText() public view returns (string memory) {
        string memory text = "";
        for (uint256 i = 0; i < _note.length; i++) {
            text = string(abi.encodePacked(
                text,
                '<tspan x="0" dy="1.2em">',
                _note[i],
                '</tspan>'
            ));
        }
        return text;
    }
}
