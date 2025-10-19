// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


/**
 * @title GuardianManager V2 (Patched)
 * @author Shamsuddeen (with Gemini AI)
 * @notice Secure wallet guardian manager with enforced spending limits and guarded social recovery.
 */
contract GuardianManager is ReentrancyGuard {
    // --- Core State Variables ---
    address public owner;
    uint256 public dailyAllowance; // Stored in wei
    uint256 public spentToday;
    uint256 public lastSpendTimestamp;

    // --- Guardian State ---
    address[] public guardians;
    mapping(address => bool) public isGuardian;

    // --- Recovery State ---
    address public proposedNewOwner;
    mapping(address => bool) public recoveryVotes;
    uint256 public recoveryVoteCount;
    bool public recoveryActive;
    uint256 public recoveryStartedAt;

    // --- Constants ---
    uint256 private constant MAX_GUARDIANS = 5;
    uint256 private constant MIN_GUARDIANS_FOR_RECOVERY = 3;
    uint256 private constant RECOVERY_WINDOW = 3 days; // votes expire after this

    // --- Events ---
    event GuardianAdded(address indexed guardian);
    event GuardianRemoved(address indexed guardian);
    event AllowanceChanged(uint256 newAllowance);
    event SpendExecuted(address indexed to, uint256 amount);
    event RecoveryInitiated(address indexed proposedOwner, address indexed initiator);
    event RecoveryVote(address indexed guardian, address indexed proposedOwner, uint256 votes);
    event OwnerRecovered(address indexed oldOwner, address indexed newOwner);
    event RecoveryCancelled(address indexed cancelledBy);

    // --- Modifiers ---
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyGuardian() {
        require(isGuardian[msg.sender], "Not guardian");
        _;
    }

    // --- Constructor ---
    constructor() {
        owner = msg.sender;
    }

    // --- Guardian Management ---
    function addGuardian(address _guardian) external onlyOwner {
        require(_guardian != address(0), "Invalid guardian address");
        require(!isGuardian[_guardian], "Address is already a guardian");
        require(guardians.length < MAX_GUARDIANS, "Max guardians reached");
        require(_guardian != owner, "Owner cannot be a guardian");

        isGuardian[_guardian] = true;
        guardians.push(_guardian);
        emit GuardianAdded(_guardian);
    }

    function removeGuardian(address _guardian) external onlyOwner {
        require(isGuardian[_guardian], "Address is not a guardian");

        isGuardian[_guardian] = false;
        uint256 len = guardians.length;
        for (uint256 i = 0; i < len; ++i) {
            if (guardians[i] == _guardian) {
                guardians[i] = guardians[len - 1];
                guardians.pop();
                break;
            }
        }

        if (recoveryVotes[_guardian]) {
            recoveryVotes[_guardian] = false;
            if (recoveryVoteCount > 0) recoveryVoteCount--;
        }

        emit GuardianRemoved(_guardian);
    }

    // --- Allowance Management ---
    function setAllowance(uint256 _newAllowance) external onlyOwner {
        dailyAllowance = _newAllowance;
        emit AllowanceChanged(_newAllowance);
    }

    // --- Spending Logic ---
    function spend(address payable _to, uint256 _amount) external onlyOwner nonReentrant {
        require(_to != address(0), "Invalid recipient");
        require(_amount > 0, "Amount > 0");

        if (block.timestamp > lastSpendTimestamp + 1 days) {
            spentToday = 0;
        }

        require(spentToday + _amount <= dailyAllowance, "Exceeds daily spending limit");
        lastSpendTimestamp = block.timestamp;
        spentToday += _amount;

        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");

        emit SpendExecuted(_to, _amount);
    }

    // --- Recovery Logic ---
    function approveRecovery(address _newOwner) external onlyGuardian nonReentrant {
        require(_newOwner != address(0) && _newOwner != owner, "Invalid or current owner");

        if (recoveryActive && (block.timestamp > recoveryStartedAt + RECOVERY_WINDOW)) {
            _resetRecoveryState();
        }

        if (!recoveryActive) {
            recoveryActive = true;
            proposedNewOwner = _newOwner;
            recoveryStartedAt = block.timestamp;
            recoveryVoteCount = 0;
            emit RecoveryInitiated(_newOwner, msg.sender);
        } else {
            require(proposedNewOwner == _newOwner, "Proposed owner mismatch");
        }

        require(!recoveryVotes[msg.sender], "Guardian has already voted");
        recoveryVotes[msg.sender] = true;
        recoveryVoteCount++;

        emit RecoveryVote(msg.sender, _newOwner, recoveryVoteCount);

        if (recoveryVoteCount >= MIN_GUARDIANS_FOR_RECOVERY) {
            _executeRecovery();
        }
    }

    function cancelRecovery() external onlyOwner {
        require(recoveryActive, "No active recovery");
        _resetRecoveryState();
        emit RecoveryCancelled(msg.sender);
    }

    function _executeRecovery() private {
        address oldOwner = owner;
        address newOwner = proposedNewOwner;
        owner = newOwner;
        _resetRecoveryState();
        emit OwnerRecovered(oldOwner, newOwner);
    }

    function _resetRecoveryState() private {
        recoveryActive = false;
        proposedNewOwner = address(0);
        recoveryVoteCount = 0;
        recoveryStartedAt = 0;
        uint256 len = guardians.length;
        for (uint256 i = 0; i < len; ++i) {
            if (recoveryVotes[guardians[i]]) {
                recoveryVotes[guardians[i]] = false;
            }
        }
    }

    // --- View Helpers ---
    function getGuardians() external view returns (address[] memory) { return guardians; }
    function getAllowance() external view returns (uint256) { return dailyAllowance; }
    function getSpentToday() external view returns (uint256) { if (block.timestamp > lastSpendTimestamp + 1 days) { return 0; } return spentToday; }
    function getRecoveryVoteCount() external view returns (uint256) { if (recoveryActive && (block.timestamp > recoveryStartedAt + RECOVERY_WINDOW)) { return 0; } return recoveryVoteCount; }
    function getProposedNewOwner() external view returns (address) { if (recoveryActive && (block.timestamp > recoveryStartedAt + RECOVERY_WINDOW)) { return address(0); } return proposedNewOwner; }
    function hasVotedFor(address _guardian) external view returns (bool) { return recoveryVotes[_guardian]; }

    // --- Fallbacks ---
    receive() external payable {}
    fallback() external payable {}
}