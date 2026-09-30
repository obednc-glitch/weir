// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ScreenedTransfer.sol";

contract ScreenedTransferTest is Test {
    ScreenedTransfer st;
    address alice = address(0xA11CE);
    address bob = address(0xB0B);
    address bad = address(0xBAD);

    function setUp() public {
        st = new ScreenedTransfer();
        st.setBlocked(bad, true);
        vm.deal(alice, 10 ether);
    }

    function testCleanRecipientReceivesFunds() public {
        vm.prank(alice);
        st.screenedTransfer{value: 1 ether}(payable(bob));
        assertEq(bob.balance, 1 ether);
        assertEq(alice.balance, 9 ether);
    }

    function testBlockedRecipientIsRefunded() public {
        vm.prank(alice);
        st.screenedTransfer{value: 1 ether}(payable(bad));
        assertEq(bad.balance, 0);
        assertEq(alice.balance, 10 ether);
    }

    function testBlockedEmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit ScreenedTransfer.Blocked(alice, bad, 1 ether);
        vm.prank(alice);
        st.screenedTransfer{value: 1 ether}(payable(bad));
    }

    function testOnlyOwnerCanEditBlocklist() public {
        vm.prank(alice);
        vm.expectRevert("not owner");
        st.setBlocked(bob, true);
    }
}
