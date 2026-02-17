// SPDX-License-Identifier: MIT
pragma solidity  >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERC1155Token is ERC1155, Ownable {

    string[] public names; //string array of names
    uint[] public ids; //uint array of ids
    string public baseMetadataURI; //the token metadata URI
    string public name; //the token mame
    uint public mintFee = 0 wei; //mintfee, 0 by default. only used in mint function, not batch.
    
    mapping(string => uint) public nameToId; //name to id mapping
    mapping(uint => string) public idToName; //id to name mapping

    /*
    constructor is executed when the factory contract calls its own deployERC1155 method. Note the Ownable(msg.sender) setting the deployer of the ERC-1155 as the owner
    */
    constructor(string memory _contractName, string memory _uri) Ownable(msg.sender) ERC1155(_uri) {
        // names = _names;
        // ids = _ids;
        // createMapping();
        setURI(_uri);
        baseMetadataURI = _uri;
        name = _contractName;
    }   

    /*
    creates a mapping of strings to ids (i.e ["one","two"], [1,2] - "one" maps to 1, vice versa.)
    */
    // 0, 1, 2
    // // NFT1, NFT2, NFT3
    // function createMapping() private {
    //     for (uint id = 0; id < ids.length; id++) {
    //         nameToId[names[id]] = ids[id];
    //         idToName[ids[id]] = names[id];
    //     }
    // }
    /*
    sets our URI and makes the ERC1155 OpenSea compatible
    */
    function uri(uint256 _tokenid) override public view returns (string memory) {
        return string(
            abi.encodePacked(
                baseMetadataURI,
                Strings.toString(_tokenid),".json"
            )
        );
    }

    function getNamesLength() public view returns (uint){
        return names.length;
    }

    function getNames() public view returns(string[] memory) {
        return names;
    }

    /*
    used to change metadata, only owner access
    */
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    /*
    set a mint fee. only used for mint, not batch.
    */
    function setFee(uint _fee) public onlyOwner {
        mintFee = _fee;
    }

    /*
    mint(address account, uint _id, uint256 amount)

    account - address to mint the token to
    _id - the ID being minted
    amount - amount of tokens to mint
    */
    function mint(address account, uint _id, uint256 amount)  
        public payable returns (uint)
    {
        require(msg.value == mintFee);
        _mint(account, _id, amount, "");
        return _id;
    }

    function addNameAndId(string memory _newName) public onlyOwner {
        // if(names.length > 0){
        //     uint id  = nameToId[_newName];
        //     require(bytes(_newName).length != bytes(names[id]).length && 
        //     keccak256(abi.encodePacked(_newName)) != keccak256(abi.encodePacked(names[id])), "Name already exists");
        // }
        
        names.push(_newName);
        ids.push(ids.length);
        nameToId[_newName] = ids[ids.length-1];
        idToName[ids[ids.length-1]] = _newName;
        
    }

    /*
    mintBatch(address to, uint256[] memory _ids, uint256[] memory amounts, bytes memory data)

    to - address to mint the token to
    _ids - the IDs being minted
    amounts - amount of tokens to mint given ID
    bytes - additional field to pass data to function
    */
    function mintBatch(address to, uint256[] memory _ids, uint256[] memory amounts, bytes memory data)
        public
    {
        _mintBatch(to, _ids, amounts, data);
    }
}