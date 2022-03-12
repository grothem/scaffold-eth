// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'base64-sol/base64.sol';
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Notepad is ERC1155, Ownable {

    uint256 public constant NOTEPAD = 0;
    mapping(address => mapping(uint256 => string[])) public notes;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() public ERC1155("") {}

    function mintItem(address to) public returns(uint256) {
        uint256 id = _tokenIds.current();
        notes[to][id] = [""];
        _tokenIds.increment();
        _mint(to, NOTEPAD, 1, "");

        return id;
    }

    function addToNote(uint256 tokenId, string memory add) public {
        require(notes[msg.sender][tokenId].length > 0, "No note to add to");
        notes[msg.sender][tokenId].push(add);
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

    function generateSVGofTokenById(address owner, uint256 tokenId) public view returns (string memory) {
        string memory svg = string(abi.encodePacked(
        '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
            '<text x="20" y="35" class="small">',
                noteAsSVGText(owner, tokenId),
            '</text>'
        '</svg>'
        ));

        return svg;
    }

    function noteAsSVGText(address owner, uint256 tokenId) public view returns (string memory) {
        string memory text = "";
        string[] memory note = notes[owner][tokenId];
        for (uint256 i = 0; i < note.length; i++) {
            text = string(abi.encodePacked(
                text,
                '<tspan x="0" dy="1.2em">',
                note[i],
                '</tspan>'
            ));
        }
        return text;
    }
}
