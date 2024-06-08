// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Storage} from "../src/Storage.sol";
import {Test, console} from "forge-std/Test.sol";


contract StorageTest is Test {
    Storage public storageContract;

    uint128 a = 11;
    uint64 b = 22;
    uint32 c = 33;
    uint32 d = 44;

    function setUp() public {
        storageContract = new Storage();
        assertEq(storageContract.slot_0_0(), 0);
    }

    function test_store() public {
        storageContract.test_store(a, b, c, d);
        assertEq(storageContract.slot_0_0(), a);
        assertEq(storageContract.slot_0_1(), b);
        assertEq(storageContract.slot_0_2(), c);
        assertEq(storageContract.slot_0_3(), d);
    }

    function test_store_offset() public {
        storageContract.test_store_offset(a, b, c, d);
        assertEq(storageContract.slot_0_0(), a);
        assertEq(storageContract.slot_0_1(), b);
        assertEq(storageContract.slot_0_2(), c);
        assertEq(storageContract.slot_0_3(), d);
    }

    function test_single_slot_struct() public {
        (uint128 a1, uint64 b1, uint64 c1) = storageContract.test_single_slot_struct();
        assertEq(a1, 1);
        assertEq(b1, 2);
        assertEq(c1, 3);
    }

    function test_multiple_slot_struct() public {
        (uint256 a2, uint256 b2, uint256 c2) = storageContract.test_multiple_slot_struct();
        assertEq(a2, 100);
        assertEq(b2, 200);
        assertEq(c2, 300);
    }

    function test_constant_immutable_storage() public {
        (uint256 a3, uint256 b3) = storageContract.test_constant_immutable_storage();
        assertEq(a3, 0);
        assertEq(b3, 321);
    }

    function test_array_storage_256() public {
        assertEq(storageContract.test_array_storage_256(8), 8);
        assertEq(storageContract.test_array_storage_256(9), 9);
        assertEq(storageContract.test_array_storage_256(10), 10);
    }

    function test_array_storage_128() public {
        assertEq(storageContract.test_array_storage_128(11, 1), 111);
        assertEq(storageContract.test_array_storage_128(11, 2), 112);
        assertEq(storageContract.test_array_storage_128(12, 1), 121);
        assertEq(storageContract.test_array_storage_128(12, 2), 122);
        assertEq(storageContract.test_array_storage_128(13, 1), 131);
        assertEq(storageContract.test_array_storage_128(13, 2), 0);
    }

    function test_array_dynamic_storage() public {
        uint256 val; // Value in array
        bytes32 b32; // bytes representation
        uint256 len; // length of array
        (val, b32, len) = storageContract.test_array_dynamic_storage(14, 0);
        assertEq(val, 141);
        assertEq(b32, 0x000000000000000000000000000000000000000000000000000000000000008d);
        assertEq(len, 3);
        (val, b32, len) = storageContract.test_array_dynamic_storage(14, 1);
        assertEq(val, 142);
        assertEq(b32, 0x000000000000000000000000000000000000000000000000000000000000008e);
        assertEq(len, 3);
        (val, b32, len) = storageContract.test_array_dynamic_storage(14, 2);
        assertEq(val, 143);
        assertEq(b32, 0x000000000000000000000000000000000000000000000000000000000000008f);
        assertEq(len, 3);

        (val, b32, len) = storageContract.test_array_dynamic_storage(15, 0);
        // uint160(151) and uint160(152) packed into val
        assertEq(val, 51722919771982646446432940329628768141463);
        assertEq(b32, 0x0000000000000000000000000000009800000000000000000000000000000097);
        assertEq(len, 3);

        (val, b32, len) = storageContract.test_array_dynamic_storage(15, 1);
        assertEq(val, 153);
        assertEq(b32, 0x0000000000000000000000000000000000000000000000000000000000000099);
        assertEq(len, 3);
    }

    function test_mapping_storage() public {
        assertEq(storageContract.test_mapping_storage(address(1)), 161);
        assertEq(storageContract.test_mapping_storage(address(2)), 162);
        assertEq(storageContract.test_mapping_storage(address(3)), 163);
    }

    function test_nested_mapping_storage() public {
        assertEq(storageContract.test_nested_mapping_storage(address(1), address(1)), 171);
        assertEq(storageContract.test_nested_mapping_storage(address(2), address(2)), 172);
        assertEq(storageContract.test_nested_mapping_storage(address(3), address(3)), 173);
    }

    function test_mapping_array_storage() public {
        uint256 value;
        uint256 array_length;
        (value, array_length) = storageContract.test_mapping_array_storage(address(1), 0);
        assertEq(value, 181);
        assertEq(array_length, 3);
        (value, array_length) = storageContract.test_mapping_array_storage(address(1), 1);
        assertEq(value, 182);
        assertEq(array_length, 3);
        (value, array_length) = storageContract.test_mapping_array_storage(address(1), 2);
        assertEq(value, 183);
        assertEq(array_length, 3);
        (value, array_length) = storageContract.test_mapping_array_storage(address(2), 0);
        assertEq(value, 1812);
        assertEq(array_length, 3);
        (value, array_length) = storageContract.test_mapping_array_storage(address(2), 1);
        assertEq(value, 1822);
        assertEq(array_length, 3);
        (value, array_length) = storageContract.test_mapping_array_storage(address(2), 2);
        assertEq(value, 1832);
        assertEq(array_length, 3);
    }

    function test_struct_array_storage() public view {
        uint256 x;
        uint128 y;
        uint128 z;
        uint256 length;
        (x, y, z, length) = storageContract.test_struct_array_storage(0);
        assertEq(x, 1911);
        assertEq(y, 1912);
        assertEq(z, 1913);
        assertEq(length, 3);
        (x, y, z, length) = storageContract.test_struct_array_storage(1);
        assertEq(x, 1921);
        assertEq(y, 1922);
        assertEq(z, 1923);
        assertEq(length, 3);
        (x, y, z, length) = storageContract.test_struct_array_storage(2);
        assertEq(x, 1931);
        assertEq(y, 1932);
        assertEq(z, 1933);
        assertEq(length, 3);
    }

}
