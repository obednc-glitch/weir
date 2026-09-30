// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// Sends native USDC (Arc's gas asset) only if the recipient is not on the blocklist.
/// A blocked attempt does not revert: funds are refunded and a Blocked event is
/// emitted, so every screening decision leaves a public on-chain record.
contract ScreenedTransfer {
    address public owner;
    mapping(address => bool) public blocked;

    event Sent(address indexed from, address indexed to, uint256 amount);
    event Blocked(address indexed from, address indexed to, uint256 amount);
    event BlocklistUpdated(address indexed account, bool isBlocked);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function screenedTransfer(address payable to) external payable {
        require(msg.value > 0, "no value");
        require(to != address(0), "zero address");

        if (blocked[to]) {
            emit Blocked(msg.sender, to, msg.value);
            (bool refunded,) = payable(msg.sender).call{value: msg.value}("");
            require(refunded, "refund failed");
            return;
        }

        emit Sent(msg.sender, to, msg.value);
        (bool ok,) = to.call{value: msg.value}("");
        require(ok, "transfer failed");
    }

    function isBlocked(address account) external view returns (bool) {
        return blocked[account];
    }

    function setBlocked(address account, bool isBlocked_) external onlyOwner {
        blocked[account] = isBlocked_;
        emit BlocklistUpdated(account, isBlocked_);
    }

    function setBlockedBatch(address[] calldata accounts, bool isBlocked_) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            blocked[accounts[i]] = isBlocked_;
            emit BlocklistUpdated(accounts[i], isBlocked_);
        }
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
