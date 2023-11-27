// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LotteryPool {

    // Owner information.
    address payable public immutable owner;
    uint totalEarnings;

    // Participant information.
    struct Participant {
        uint amountPaid;       // Total fee paid to enter.
        bool isActive;         // Active in lottery or not.
        uint enteredAtCounter; // Lottery Number they entered in.
        uint gamesWon;
    }

    mapping(address => Participant) public participants;
    address payable[] private currentParticipants; // Current lottery participants.

    // Fee calculations.
    uint constant baseFee = .1 ether;
    uint constant increaseFeePerWin = .01 ether;

    // Lottery counter.
    uint private lotteryNumber = 1; 
    
    // Winner information.
    address public previousWinner;

    // For noReentrant modifier.
    bool private locked;

    // Set contract owner.
    constructor() {owner = payable(msg.sender);}

    // Prevent Re-entrancy Attacks.
    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    // For participants to enter the lottery.
    function enter() public payable noReentrant {
        require(msg.sender != owner, "Owner cannot enter the lottery!");
        require(participants[msg.sender].enteredAtCounter < lotteryNumber, "You have already entered!");

        uint totalFee = (baseFee + (increaseFeePerWin * participants[msg.sender].gamesWon));
        require(msg.value == totalFee, "Incorrect entry fee");

        // Update participant details, add them to current participants array.
        participants[msg.sender] = Participant(totalFee, true, lotteryNumber, participants[msg.sender].gamesWon);
        currentParticipants.push(payable(msg.sender));

        // Calculate and transfer owner's share.
        uint ownerShare = totalFee / 10;
        totalEarnings += ownerShare;
        payable(owner).transfer(ownerShare);


        // Automatically select a winner when there are 5 participants.
        if(currentParticipants.length == 5) {
            selectWinner();
        }
    }

    // Randomly select a winner, transfer winning balance and prepare next round.
    function selectWinner() private {
        uint random = uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, currentParticipants))) % currentParticipants.length;
        address payable winner = currentParticipants[random];

        // Increment games won for winner.
        participants[winner].gamesWon++;

        // Set previous winner.
        previousWinner = winner;

        // Transfer balance to winner.
        (bool sendToWinner, ) = winner.call{value: address(this).balance}("");
        require(sendToWinner, "Failed to send Ether to winner");

        // Prepare next round.
        lotteryNumber++;
        delete currentParticipants;
    }

    // For participants to withdraw from the lottery.
    function withdraw() public noReentrant {
        require(msg.sender != owner, "Owner cannot withdraw as they cannot enter the event!");
        require(participants[msg.sender].enteredAtCounter == lotteryNumber, "You have not entered this lottery!");
        require(participants[msg.sender].isActive, "You have already withdrawn");

        // Check and remove the sender from the current participants array.
        bool isParticipant = false;
        for (uint i = 0; i < currentParticipants.length; i++) {
            if (currentParticipants[i] == payable(msg.sender)) {
                currentParticipants[i] = currentParticipants[currentParticipants.length - 1];
                currentParticipants.pop();
                isParticipant = true;
                break;
            }
        }

        require(isParticipant, "You have not entered this lottery!");

        // Calculate the refund amount.
        uint totalFee = baseFee + (increaseFeePerWin * participants[msg.sender].gamesWon);
        uint refundAmount = participants[msg.sender].amountPaid - ((totalFee * 10) / 100);
        require(refundAmount > 0, "No funds to withdraw");

        // Update state before transferring Ether.
        participants[msg.sender].isActive = false;
        participants[msg.sender].enteredAtCounter = lotteryNumber - 1;
        participants[msg.sender].amountPaid = 0;

        // Transfer refund amount.
        (bool success, ) = payable(msg.sender).call{value: refundAmount}("");
        require(success, "Failed to send Ether");
    }

    // To view participants in current lottery.
    function viewParticipants() public view returns (address payable [] memory, uint) {
        return (currentParticipants, currentParticipants.length);
    }

    // To view winner of the last lottery.
    function viewPreviousWinner() public view returns (address) {
        require(previousWinner != address(0), "No winner has been selected yet");
        return previousWinner;
    }

    // To view the amount earned by Owner.
    function viewEarnings() public view returns (uint256) {
        require(msg.sender == owner, "You must be the owner of this contract!");
        return totalEarnings;
    }

    // To view the balance in the current lottery.
    function viewPoolBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
