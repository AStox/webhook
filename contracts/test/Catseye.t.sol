// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, Vm} from "forge-std/Test.sol";
import {Catseye} from "../src/Catseye.sol";

contract CatseyeTest is Test {
    Catseye public catseye;
    address oracle = address(0xBEEF);
    
    event Query(address indexed caller, string message, bytes32 indexed queryId);
    event QueryResult(bytes32 indexed queryId, string result);

    function setUp() public {
        catseye = new Catseye(oracle);
    }

    function testQueryEmitsEvent() public {
        string memory query = "SELECT * FROM users";
        
        // Capture the queryId from the event
        vm.recordLogs();
        catseye.requestQuery(query);
        
        Vm.Log[] memory entries = vm.getRecordedLogs();
        require(entries.length > 0, "No event emitted");
        
        // Event data: [0] = caller (indexed), [1] = queryId (indexed), [2] = message (not indexed)
        bytes32 emittedQueryId = entries[0].topics[2];
        assertEq(entries[0].topics[1], bytes32(uint256(uint160(address(this)))));
        assertEq(abi.decode(entries[0].data, (string)), query);
        
        // Verify state was set correctly for this queryId
        assertTrue(catseye.pendingQueries(emittedQueryId));
        assertEq(catseye.getQueryOwner(emittedQueryId), address(this));
    }

    function testCallbackOnlyOracle() public {
        string memory query = "SELECT * FROM users";
        
        vm.recordLogs();
        catseye.requestQuery(query);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 queryId = entries[0].topics[2];
        
        string memory result = "result";
        vm.expectRevert("Only oracle can callback");
        catseye.callback(queryId, result);
    }

    function testCallbackRequiresPendingQuery() public {
        bytes32 queryId = bytes32(uint256(1));
        string memory result = "result";
        
        vm.prank(oracle);
        vm.expectRevert("Query not found or already fulfilled");
        catseye.callback(queryId, result);
    }

    function testSuccessfulCallback() public {
        string memory query = "SELECT * FROM users";
        
        vm.recordLogs();
        catseye.requestQuery(query);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 queryId = entries[0].topics[2];
        
        string memory result = "result";
        vm.expectEmit(true, true, true, true);
        emit QueryResult(queryId, result);
        
        vm.prank(oracle);
        catseye.callback(queryId, result);
        
        assertFalse(catseye.isPending(queryId));
    }

    function testFuzzQuery(string memory query) public {
        vm.assume(bytes(query).length > 0);
        
        vm.recordLogs();
        catseye.requestQuery(query);
        
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 queryId = entries[0].topics[2];
        
        assertTrue(catseye.isPending(queryId));
        assertEq(catseye.getQueryOwner(queryId), address(this));
    }
}