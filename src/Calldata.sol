// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
contract Calldata {

    uint256 public Uint;
    bool public Bool;

    struct Struct {
        bool _bool;
        address _address;
        uint128 _uint128;
        uint64 _uint64;
    }
    // This function will create the first four bytes of a contract call
    // Its the keccak256 of the function name and inputs

    constructor(uint256 _Uint, bool _Bool) {
        Uint = _Uint;
        Bool = _Bool;
    }


    function createSelector(string calldata _funcName) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_funcName)));
    }

    function test_calldata_bool() external view returns (bool) {
        return Bool;
    }

    function test_calldata_uint() external view returns (uint256) {
        return Uint;
    }

    // Each parameter will be a 32 bytes hex string
    // 4 bytes function selector
    // 1st input = 32 bytes parameter zero padded from the left
    function test_calldata_with_parameter_address(address _address) external view returns (address) {
        return _address;
    }

    function test_calldata_with_parameter_uint(uint256 _uint256) external pure returns (uint256) {
        return _uint256;
    }

    function test_calldata_with_parameter_uint128(uint128 _uint128) external pure returns (uint128) {
        return _uint128;
    }

    function test_calldata_with_parameter_two_uint128(uint128 _uint128, uint128 __uint128) external pure returns (uint128, uint128) {
        return (_uint128, __uint128);
    }

    function test_calldata_with_parameter_struct(Struct calldata _struct) external pure returns (Struct calldata) {
        return _struct;
    }
}
