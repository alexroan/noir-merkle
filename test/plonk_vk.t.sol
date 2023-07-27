// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {UltraVerifier} from "verifier/plonk_vk.sol";

contract UltraVerifierTest is Test {
    UltraVerifier public s_verifier;

    function setUp() public {
        s_verifier = new UltraVerifier();
    }

    function testVerify() public {
        bytes32[] memory publicInputs = new bytes32[](3);
        // Must be same order as in the circuit
        publicInputs[0] = 0x00000000000000000000000070997970c51812dc3a010c7d01b50e0d17dc79c8; // recipient
        publicInputs[1] = 0x0f72910fa39249cc44881a98f91cde964f1ae2694dd627973b9578984f0f7a94; // note_root
        publicInputs[2] = 0x22074c34b69bb85c360e2e8cc02a7a223388ba735aa1cf0bf8d0163b960e5876; // nullifier_hash
        assertTrue(s_verifier.verify(vm.parseBytes(vm.readLine("./circuits/proofs/main.proof")), publicInputs));
    }
}
