// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Memory} from "../src/Memory.sol";
import {Test, console} from "forge-std/Test.sol";


contract MemoryTest is Test {
    Memory public memoryContract;

    function setUp() public {
        memoryContract = new Memory();
    }

    function test_memory() public {
        bytes32 _b32 = bytes32(uint256(1));
        bytes32 b32 = memoryContract.test_memory(_b32);
        assertEq(b32, _b32);
    }

    function test_memory_2() public {
        bytes32 _b0 = bytes32(uint256(1));
        bytes32 _b1 = bytes32(uint256(2));
        bytes32 b0;
        bytes32 b1;
        (b0, b1) = memoryContract.test_memory_2(_b0, _b1);
        assertEq(b0, bytes32(uint256(0)));
        assertEq(b1, bytes32(uint256(2)));
    }
}