//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VoteStorage {
    // Initialization
    address public owner;

    constructor() {
        owner = msg.sender;
        authNodes[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Authorized Nodes

    mapping(address => bool) public authNodes;

    function addNode(address _node) public onlyOwner {
        authNodes[_node] = true;
    }

    function removeNode(address _node) public onlyOwner {
        authNodes[_node] = false;
    }

    modifier checkNodeAuth() {
        require(authNodes[msg.sender]);
        _;
    }

    // Vote Details

    mapping(string => uint256) optionToVoteCount;
    mapping(string => bool) optionExists;

    string[] public options;

    function addOption(string memory _name) public onlyOwner {
        require(!optionExists[_name], "Option already exists");
        options.push(_name);
        optionToVoteCount[_name] = 0;
        optionExists[_name] = true;
    }

    function getVoteCount(string memory _name)
        public
        view
        checkNodeAuth
        returns (uint256)
    {
        return optionToVoteCount[_name];
    }

    function incrementVote(string memory _name) public checkNodeAuth {
        optionToVoteCount[_name]++;
    }

    function resetOptions() public onlyOwner {
        for (uint256 i = 0; i < options.length; i++) {
            optionToVoteCount[options[i]] = 0;
            optionExists[options[i]] = false;
        }
        delete options;
    }
}
