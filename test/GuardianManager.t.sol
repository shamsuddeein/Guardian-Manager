// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {GuardianManager} from "../src/GuardianManager.sol";

/**
 * @notice Basic unit tests for the GuardianManager contract.
 */
contract GuardianManagerTest is Test {
    GuardianManager public guardianManager;
    address public owner;
    address public guardian1 = makeAddr("guardian1");
    address public guardian2 = makeAddr("guardian2");
    address public nonOwner = makeAddr("nonOwner");

    /**
     * @dev Sets up the test environment before each test case.
     */
    function setUp() public {
        // Deploy the contract. 'address(this)' becomes the initial owner.
        guardianManager = new GuardianManager();
        owner = guardianManager.owner();
    }

    // --- Test: Add Guardian ---

    function test_AddGuardian_Succeeds() public {
        guardianManager.addGuardian(guardian1);
        assertTrue(guardianManager.isGuardian(guardian1));
        assertEq(guardianManager.getGuardians().length, 1);
        assertEq(guardianManager.getGuardians()[0], guardian1);
    }

    function test_Fail_AddGuardian_WhenNotOwner() public {
        vm.prank(nonOwner); // Simulate call from a different address
        vm.expectRevert("GuardianManager: Caller is not the owner");
        guardianManager.addGuardian(guardian1);
    }

    function test_Fail_AddGuardian_WhenAlreadyExists() public {
        guardianManager.addGuardian(guardian1);
        vm.expectRevert("GuardianManager: Address is already a guardian");
        guardianManager.addGuardian(guardian1);
    }

    // --- Test: Remove Guardian ---

    function test_RemoveGuardian_Succeeds() public {
        guardianManager.addGuardian(guardian1);
        guardianManager.addGuardian(guardian2);

        guardianManager.removeGuardian(guardian1);
        
        assertFalse(guardianManager.isGuardian(guardian1));
        assertTrue(guardianManager.isGuardian(guardian2)); // Make sure the other guardian is still there
        assertEq(guardianManager.getGuardians().length, 1);
    }

    function test_Fail_RemoveGuardian_WhenNotGuardian() public {
        vm.expectRevert("GuardianManager: Address is not a guardian");
        guardianManager.removeGuardian(guardian1);
    }

    // --- Test: Set Allowance ---

    function test_SetAllowance_Succeeds() public {
        uint256 newAllowance = 500;
        guardianManager.setAllowance(newAllowance);
        assertEq(guardianManager.getAllowance(), newAllowance);
    }

    function test_Fail_SetAllowance_WhenNotOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert("GuardianManager: Caller is not the owner");
        guardianManager.setAllowance(500);
    }
}
