// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Storage {

    /////////// BASIC VARIABLES //////////

    // Slot 0: Totals 32 Bytes = 256 bits
    uint128 public slot_0_0;
    uint64 public slot_0_1;
    uint32 public slot_0_2;
    uint32 public slot_0_3;

    // Slot 1: Totals 32 Bytes = 256 bits
    address public slot_1_0; // address = 20 bytes = 160 bits
    uint64 public slot_1_1;
    uint32 public slot_1_2;

    function test_store(uint128 a, uint64 b, uint32 c, uint32 d) public {
        assembly {

            /*
                Storage for slot 0:
                s4 | s3 | s2 | s1
                32 | 32 | 64 | 128 = 256

                CHANGE slot_0_0 TO 11
                1. Load the whole 32 bytes (256 bits) from slot 0
                2. Create a bit mask of 128 1s and 128 0s so we only change the last 128 bits
                3. Change the last 128 bits to uint128(11)
                4. Store that whole 256 bit variable in slot 0
            */
            let v := sload(0)
            /*
                State vars are packed right to left
                For slot 0
                stateVar4 (32 bits), stateVar3 (32 bits), stateVar2 (64 bits), stateVar1 (128 bits)

                Create bit mask
                1 at the 128 position and all zeros = shl(128, 1) == 0 x 128, 1, 0 x 127
                Create 1s after the 128 position = sub(shl(128, 1), 1) == 0 x 128, 1 x 128
                Flip the 1s and 0s = not(sub(shl(128, 1), 1))) == 1 x 128, 0 x 128
            */
            let mask_a := not(sub(shl(128, 1), 1))
            // mask_a = 128x1 | 128x0

            v := and(v, mask_a)
            /*
                v = 128x1 and the 128 bits stored on the right of sload
                and() replaces the 0 bits from mask_a with the bits in that place from v
                Which is the stateVar1 uint128
                so v = 128x1, stateVar1 from slot 0
             */
            v := or(v, a) // Change v to a
            /*
                or() keeps the 128x1 at the beginning
                then changes the 128 bits at the end to be a

                CHANGE slot_0_1 TO 22
                1. load slot 0
                2. create bitmask at 64 bit position
                a = shl(64, 1) = 192x0, 1, 63x0
                b = sub(a, 1) = 192x0, 64x1
                c = shl(128, b) = 64x0, 64x1, 128x0
                d = not(c) = 64x1, 64x0, 128x1 | Flips the above 0s and 1s
                64x1 | 64x0 | 128x1
            */
            let mask_b := not(shl(128, sub(shl(64, 1), 1)))
            v := and(v, mask_b)
            v := or(v, shl(128, b))
            /*
                3. Change that to uint64(b)
                4. Store the whole 256 bit packed variables in slot 0


                CHANGE slot_0_2 TO c
                mask_c = 32 bit 1s | 32 bit 0s | 64 bit 1s | 128 bit 1s
                32x1 | 32x0 | 64x1 | 128x1
            */
            let mask_c := not(shl(192, sub(shl(32, 1), 1)))
            v := and(v, mask_c)
            v := or(v, shl(192, c))

            /*
                CHANGE slot_0_3 to 44
                mask_d = 32 bit 0s | 32 bit 1s | 64 bit 1s | 128 bit 1s
                mask_d = 32 bit 0s | 224 bit 1s
                32x0 | 32x1 | 64x1 | 128x1
                32x0 | 224x1
            */
            let mask_d := not(shl(224, sub(shl(32, 1), 1)))
            v := and(v, mask_d)
            v := or(v, shl(224, d))

            sstore(0, v) // In slot 0 store v. One by one we changed the bits to different numbers
        }
    }

    // Use offsets instead of hardcoded variables
    function test_store_offset(uint128 a, uint64 b, uint32 c, uint32 d) public {
        assembly {
            let v := sload(slot_0_0.slot)

            let mask_a := not(sub(shl(128, 1), 1))
            v := and(v, mask_a)
            v := or(v, a)

            let mask_b := not(shl(mul(slot_0_1.offset, 8), sub(shl(64, 1), 1)))
            v := and(v, mask_b)
            v := or(v, shl(mul(slot_0_1.offset, 8), b))


            let mask_c := not(shl(mul(slot_0_2.offset, 8), sub(shl(64, 1), 1)))
            v := and(v, mask_c)
            v := or(v, shl(mul(slot_0_2.offset, 8), c))

            let mask_d := not(shl(mul(slot_0_3.offset, 8), sub(shl(64, 1), 1)))
            v := and(v, mask_d)
            v := or(v, shl(mul(slot_0_3.offset, 8), d))

            sstore(0, v)
        }
    }


    //////////// STRUCTS ////////////
    struct SingleSlot {
        uint128 a;
        uint64 b;
        uint64 c;
    }

    struct MultipleSlot {
        uint256 a;
        uint256 b;
        uint256 c;
    }

    // Slot 2
    SingleSlot public slot_2 = SingleSlot({a: 1, b: 2, c:3});

    // Slot 3, 4, 5
    MultipleSlot public slot_3_4_5 = MultipleSlot({a: 100, b: 200, c:300});

    function test_single_slot_struct() public view returns (uint128 a1, uint64 b1, uint64 c1) {
        assembly {
            let s := sload(2)
            // a 128 bits, b 64 bits, c 64 bits
            a1 := s
            b1 := shr(128, s)
            c1 := shr(192, s)
        }
    }

    function test_multiple_slot_struct() public view returns (uint256 a2, uint256 b2, uint256 c2) {
        assembly {
            a2 := sload(3)
            b2 := sload(4)
            c2 := sload(5)
        }
    }



    ////////// CONSTANTS / IMMUTABLES ///////////
    // Constants and immutables are stored in the byte code of the contract
    // They are not stored in storage

    uint256 public slot_6 = 0;
    uint256 public constant bytecode = 123; // Created during compile time
    address public immutable bytecode2; // Created during runtime
    uint256 public slot_7 = 321;

    function test_constant_immutable_storage() public view returns (uint256 a3, uint256 b3) {
        assembly {
            a3 := sload(6)
            b3 := sload(7)
        }
    }


    //////////// ARRAYS ///////////////

    // For fixed size arrays the storage begins at the index where the array is defined
    uint256[3] public slot_8_9_10 = [8, 9, 10];

    uint128[5] public slot_11_12_13 = [111, 112, 121, 122, 131];

    function test_array_storage_256(uint256 i) public view returns (uint256 v) {
        assembly {
            v := sload(i)
        }
    }

    function test_array_storage_128(uint128 i, uint8 side) public view returns (uint128 v) {
        assembly {

            let storageSlot := sload(i)
            // If index is even/odd
            switch side
            // If odd: shift bytes 128 right
            case 2 {
                v := shr(128, storageSlot)
            }
            // If even cast storageSlot to uint128
            default {
                v := storageSlot
            }
        }
    }


    //////////// DYNAMIC ARRAYS //////////////
    uint256[] public slot_14 = [141,142,143];
    /*
        Slot of element =
            keccak256(slot where array is declared) + size of element * index of element
            1: keccack256(14) + 1 * 0 = keccak256(14)
            2: keccack256(14) + 1 * 1 = keccak256(14) + 1
            3: keccak256(14) + 1 * 2 = keccak256(14) + 2
    */

    uint128[] public slot_15 = [151, 152, 153];
    /*
        11: keccack256(17) + 0.5 * 0 = keccak256(17)
        22: keccack256(17) + 0.5 * 1 = keccak256(17) + 0.5
        33: keccak256(18) + 0.5 * 2 = keccak256(18) + 1
    */

    function test_array_dynamic_storage(uint256 slot, uint256 index) public view
    returns (uint256 val, bytes32 b32, uint256 len) {
        bytes32 start = keccak256(abi.encode(slot));

        assembly {
            // Length of array will be stored in slot that the array is declared
            len := sload(slot)
            val := sload(add(start, index))
            b32 := val
        }
    }



    ///////////// MAPPINGS /////////////////
    // Slot of value = keccak256(key, slot where mapping is declared)
    mapping(address => uint256) public slot_16;
    // Nested Mapping
    // slot of value = keccak256(key1, keccak256(key0, slot where mapping is declared))
    mapping(address => mapping(address => uint256)) public slot_17;



    function test_mapping_storage(address _address) public view returns (uint256 v) {
        // slot of value = keccak256(key, slot where mapping is declared)
        bytes32 slot = keccak256(abi.encode(_address, 16));
        assembly {
            v := sload(slot)
        }
    }

    function test_nested_mapping_storage(address _address1, address _address2) public view returns (uint256 v) {
        // slot of value = keccak256(key2, keccak256(key1, slot where mapping is declared))
        bytes32 innerSlot = keccak256(abi.encode(_address1, uint256(17)));
        bytes32 outerSlot = keccak256(abi.encode(_address2, innerSlot));

        assembly {
            v := sload(outerSlot)
        }
    }

    /*
        Slot of value in mapping = keccak256(key, slot)
        Slot of array element = keccak256(slot) + index
        Slot of array element in mapping = keccak(keccak256(key, slot)) + index
    */
    mapping(address => uint256[]) public slot_18;
    function test_mapping_array_storage(address key, uint256 array_index) public view returns (uint256 value, uint256 array_length) {
        // Slot of array element in mapping = keccak(keccak256(key, slot)) + index

        uint256 mapping_slot = 18;
        // Inner keccak256
        bytes32 mapping_hash = keccak256(abi.encode(key, mapping_slot));
        // Outer keccak256
        bytes32 array_hash = keccak256(abi.encode(mapping_hash));

        assembly {
            array_length := sload(mapping_hash)
            value := sload(add(array_hash, array_index))
        }
    }


    /*
        Dynamic array of structs
        Slot of struct in array = keccak256(slot where declared) + size of element * index of element
        keccak256(19) + size of element + index of element
    */
    struct Point {
        uint256 x;
        uint128 y;
        uint128 z;
    }

    Point[] private slot_19;


    function test_struct_array_storage(uint256 index) public view returns (uint256 x, uint128 y, uint128 z, uint256 length) {
        // Slot of struct in array = keccak256(slot where declared) + size of element * index of element
        bytes32 start = keccak256(abi.encode(uint256(19)));

        assembly {
            length := sload(19)
            x := sload(add(start, mul(2, index))) // size of element = 2 because Point takes two slots (uint256 | uint128 + uint128)
            let zy := sload(add(start, add(mul(2, index), 1)))
            y := zy
            z := shr(128, zy)
        }
    }


    constructor() {
        bytecode2 = msg.sender;

        slot_16[address(1)] = 161;
        slot_16[address(2)] = 162;
        slot_16[address(3)] = 163;

        slot_17[address(1)][address(1)] = 171;
        slot_17[address(2)][address(2)] = 172;
        slot_17[address(3)][address(3)] = 173;

        slot_18[address(1)].push(181);
        slot_18[address(1)].push(182);
        slot_18[address(1)].push(183);
        slot_18[address(2)].push(1812);
        slot_18[address(2)].push(1822);
        slot_18[address(2)].push(1832);

        slot_19.push(Point(1911, 1912, 1913));
        slot_19.push(Point(1921, 1922, 1923));
        slot_19.push(Point(1931, 1932, 1933));
    }
}
