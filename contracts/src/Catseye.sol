// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Catseye {
    event Query(address indexed caller, string message, bytes32 indexed queryId);
    event QueryResult(bytes32 indexed queryId, string result);

    address public immutable oracle;
    mapping(bytes32 => bool) public pendingQueries;
    mapping(bytes32 => address) public queryOwners;

    constructor(address _oracle) {
        oracle = _oracle;
    }

    function generateQueryId(address sender, string memory _query) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(sender, _query, block.timestamp));
    }

    function query(string memory _query) public {
        bytes32 queryId = generateQueryId(msg.sender, _query);
        pendingQueries[queryId] = true;
        queryOwners[queryId] = msg.sender;
        
        emit Query(msg.sender, _query, queryId);
    }

    function callback(bytes32 _queryId, string memory _result) public {
        require(msg.sender == oracle, "Only oracle can callback");
        require(pendingQueries[_queryId], "Query not found or already fulfilled");
        
        pendingQueries[_queryId] = false;
        emit QueryResult(_queryId, _result);
    }

    // View functions
    function isPending(bytes32 _queryId) public view returns (bool) {
        return pendingQueries[_queryId];
    }

    function getQueryOwner(bytes32 _queryId) public view returns (address) {
        return queryOwners[_queryId];
    }
} 