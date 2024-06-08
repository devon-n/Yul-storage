// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import {Test, console} from "forge-std/Test.sol";

contract Memory {

    /*
        Writing to memory will left pack until the 32 bytes are full
        Passing bytes32(uint256(1)) = 0x0000000000000000000000000000000000000000000000000000000000000001
    */
    function test_memory(bytes32 _b32) public pure returns (bytes32 b32) {
        assembly {
            let p := mload(0x40)
            mstore(p, _b32)
            b32 := mload(p)
        }
    }
    /*
        This will overwrite previously written to memory slots
        Passing bytes32(uint256(1)) at slot 0 = 0x0000000000000000000000000000000000000000000000000000000000000001
        Passing bytes32(uint256(2)) at slot 1 = 0x0000000000000000000000000000000000000000000000000000000000000002
            and will overwrite the previous 1
        This function will return 0x0000000000000000000000000000000000000000000000000000000000000000 at slot 1
        and 0x0000000000000000000000000000000000000000000000000000000000000002 at slot 2
    */
    function test_memory_2(bytes32 _b0, bytes32 _b1) public pure returns (bytes32 b0, bytes32 b1) {
        assembly {
            // This will write to memory
            mstore(0, _b0)
            // This will overwrite the previous line (_b0)
            // And store _b1 1 byte to the right
            mstore(1, _b1)
            b0 := mload(0)
            b1 := mload(1)
        }
    }
}