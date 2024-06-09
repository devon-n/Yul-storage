// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Calldata} from "../src/Calldata.sol";
import {Test, console} from "forge-std/Test.sol";


contract CalldataTest is Test {
    Calldata public calldataContract;

    uint256 _uint256 = 123456;
    uint128 _uint128 = 654321;
    uint64 _uint64 = 3333;
    address alice = makeAddr("alice");

    struct Struct {
        bool _bool;
        address _address;
        uint128 _uint128;
        uint64 _uint64;
    }

    function setUp() public {
        calldataContract = new Calldata(_uint256, true);
    }

    function test_calldata_bool() public {
        bytes memory functionSignature = abi.encodeWithSignature("test_calldata_bool()");
        console.logBytes(functionSignature);
        // 0x5b57a5e8 = abi.encodeWithSignature("test_calldata_bool")
        // First 4 bytes = 8 characters
        (bool results, bytes memory data) = address(calldataContract).call(functionSignature);
        bool bytesAsBool = bytes32(data) != 0;
        assertEq(bytesAsBool, calldataContract.Bool());
    }

    function test_calldata_uint() public {
        bytes memory functionSignature = abi.encodeWithSignature("test_calldata_uint()");
        console.logBytes(functionSignature);
        // 0x112f7992 = abi.encodeWithSignature("test_calldata_uint")
        // First 4 bytes = 8 characters
        (bool results, bytes memory data) = address(calldataContract).call(functionSignature);
        console.logBytes(data);
        assertEq(bytes32(data), bytes32(calldataContract.Uint()));
        // 0x000000000000000000000000000000000000000000000000000000000001e240
        assertEq(uint256(bytes32(data)), calldataContract.Uint());
    }


    function test_calldata_with_parameter_address() public {
        bytes memory functionSignature = abi.encodeWithSignature("test_calldata_with_parameter_address(address)", alice);

        // Manual construction of function signature
        bytes memory functionSignatureWithoutParam = abi.encodeWithSignature("test_calldata_with_parameter_address(address)");
        bytes memory manualFunctionSignature = (
            abi.encodePacked(
                functionSignatureWithoutParam, // 4 bytes
                bytes12(0x0), // 12 bytes
                alice // 20 bytes
                // Total = 36 bytes
            )
        );
        // bytes12 + alice = 32 bytes for first slot (address = 20 bytes)
        (bool results1, bytes memory data1) = address(calldataContract).call(functionSignature);
        (bool results2, bytes memory data2) = address(calldataContract).call(manualFunctionSignature);
        assertEq(functionSignature.length, 36);
        assertEq(functionSignature, manualFunctionSignature);
        assertEq(data1, data2);
    }
    function test_calldata_with_parameter_uint256() public {
        bytes memory functionSignature = abi.encodeWithSignature("test_calldata_with_parameter_uint(uint256)", _uint256);

        // Manual construction of function signature
        bytes memory functionSignatureWithoutParam = abi.encodeWithSignature("test_calldata_with_parameter_uint(uint256)");
        bytes memory manualFunctionSignature = (abi.encodePacked(
            functionSignatureWithoutParam, // 4 bytes
            _uint256 // 32 bytes
            // Total = 36 bytes
        ));
        (bool results1, bytes memory data1) = address(calldataContract).call(functionSignature);
        (bool results2, bytes memory data2) = address(calldataContract).call(manualFunctionSignature);
        assertEq(functionSignature.length, 36);
        assertEq(functionSignature, manualFunctionSignature);
        assertEq(data1, data2);
    }
    function test_calldata_with_parameter_uint128() public {
        bytes memory functionSignature = abi.encodeWithSignature("test_calldata_with_parameter_uint128(uint128)", _uint128);

        // Manual construction of function signature
        bytes memory functionSignatureWithoutParam = abi.encodeWithSignature("test_calldata_with_parameter_uint128(uint128)");
        bytes memory manualFunctionSignature = (abi.encodePacked(
            functionSignatureWithoutParam, // 4 bytes
            bytes16(0x0), // 16 bytes
            _uint128 // 128bits / 8 bytes = 16 bytes
            // Total = 36 bytes
        ));
        (bool results1, bytes memory data1) = address(calldataContract).call(functionSignature);
        (bool results2, bytes memory data2) = address(calldataContract).call(manualFunctionSignature);
        assertEq(functionSignature.length, 36);
        assertEq(functionSignature, manualFunctionSignature);
        assertEq(data1, data2);
    }

    function test_calldata_with_parameter_two_uint128() public {
        bytes memory functionSignature = abi.encodeWithSignature("test_calldata_with_parameter_two_uint128(uint128,uint128)", _uint128, _uint128);

        // Manual construction of function signature
        bytes memory functionSignatureWithoutParam = abi.encodeWithSignature("test_calldata_with_parameter_two_uint128(uint128,uint128)");
        bytes memory manualFunctionSignature = (abi.encodePacked(
            functionSignatureWithoutParam, // 4 bytes
            bytes16(0x0), // 16 bytes
            _uint128, // 16 bytes
            bytes16(0x0), // 16 bytes
            _uint128 // 16 bytes
            // Total = 68 bytes
        ));
        (bool results1, bytes memory data1) = address(calldataContract).call(functionSignature);
        (bool results2, bytes memory data2) = address(calldataContract).call(manualFunctionSignature);
        assertEq(functionSignature.length, 68);
        assertEq(functionSignature, manualFunctionSignature);
        assertEq(data1, data2);
    }

    function test_calldata_with_parameter_struct() public {
        Struct memory StructParam = Struct(true, alice, _uint128, _uint64);
        bytes memory functionSignature = abi.encodeWithSignature("test_calldata_with_parameter_struct((bool,address,uint128,uint64))", StructParam);

        // Manual construction of function signature
        bytes memory functionSignatureWithoutParam = abi.encodeWithSignature("test_calldata_with_parameter_struct((bool,address,uint128,uint64))");

        // We encode the struct first
        bytes memory StructParamEncoded = abi.encode(StructParam);
        console.logBytes(StructParamEncoded);
        /*

        The structs are encoded without packing so the length is the number of params
        4 params, 32 bytes each

        4 x 32 = 128
        + 4 bytes of function selector = 132
        0x
        0000000000000000000000000000000000000000000000000000000000000001 = bool
        000000000000000000000000328809bc894f92807417d2dad6b7c998c1afdac6 = address
        000000000000000000000000000000000000000000000000000000000009fbf1 = uint128
        0000000000000000000000000000000000000000000000000000000000000d05 = uint64

        struct Struct {
            bool _bool;
            address _address;
            uint128 _uint128;
            uint64 _uint64;
        }

         */
        // Then encodePacked with the signature
        bytes memory manualFunctionSignature = (abi.encodePacked(functionSignatureWithoutParam, StructParamEncoded));
        (bool results1, bytes memory data1) = address(calldataContract).call(functionSignature);
        (bool results2, bytes memory data2) = address(calldataContract).call(manualFunctionSignature);

        assertEq(StructParamEncoded.length, 128);
        assertEq(functionSignature.length, 132);
        assertEq(functionSignature, manualFunctionSignature);
        assertEq(data1, data2);
    }
}
