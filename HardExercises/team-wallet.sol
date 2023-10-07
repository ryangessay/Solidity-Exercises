// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Allow for setting various Team Members with an inital amount of credits
//which they can suggest spending it in various amounts
//and then voting on those suggested transactions
//with approved transactions being debited
contract TeamWallet {

    address owner;
    address[] teamMembers;
    uint totalCredits;
    uint transactionCounter;
    bool walletInitialized;

    enum Status { Pending, Debited, Failed}

    struct Transaction {
        uint amount;
        Status status;
    }

    struct VoteCount {
        uint approvals;
        uint denials;
    }

    mapping(address => uint) requestToSpend;
    mapping(uint => Transaction) transactionNumber;
    mapping(uint => VoteCount) transactionVotes;
    mapping(uint => mapping(address => bool)) hasVoted;


    constructor() {owner = msg.sender;}
    
    modifier onlyTeamMembers() {
        for (uint i=0; i<teamMembers.length; i++) {
            if (teamMembers[i] == msg.sender) {
                _;
                return;
            }
        }
        revert('Only team members can call this function');
    } 

    //initialize the team members and credits 
    function setWallet(address[] memory _members, uint256 _credits) public {
        require(msg.sender == owner, 'Only the contract owner can run this function');
        require(_members.length >= 1, 'Please enter at least one member');
        require(_credits > 0, 'Please enter more than 0 credits');
        require(walletInitialized == false, 'Wallet has already been setup');
        
        //check to make sure owner address is not input as _members
        for (uint i=0; i<_members.length; i++) {
            require(_members[i] != owner, 'Contract owner cannot be a member');
        }

        //set global teamMembers and totalCredits
        teamMembers = _members;
        totalCredits = _credits;

        //function cannot be called again
        walletInitialized = true;
    }

    //writes a suggested transaction for the entered amount, that can either be approved or denied
    //instantly denied if suggested amount is greater than total credits
    function spend(uint256 _amount) public onlyTeamMembers {
        require(_amount > 0, 'Please enter more than 0 credits');

        //transaction denied if amount is greater than available credits
        if(_amount > totalCredits) {
            transactionCounter++;
            transactionNumber[transactionCounter] = Transaction({
            amount: _amount,
            status: Status.Failed
        });
            return;
        } 

        //transaction recorded and status set to pending
        requestToSpend[msg.sender] = _amount;
        transactionCounter++;
        transactionNumber[transactionCounter] = Transaction({
            amount: _amount,
            status: Status.Pending
        });

        //runs through approve function to run all checks
        approve(transactionCounter);
    }

    //vote for approving a transaction amount
    function approve(uint256 _n) public onlyTeamMembers {
        require(_n <= transactionCounter && _n > 0, 'Invalid transaction number');
        require(hasVoted[_n][msg.sender] == false, 'You have already voted');
        require(transactionNumber[_n].status == Status.Pending, "Transaction has already been approved or has already been denied");

        //can only vote once
        hasVoted[_n][msg.sender] = true;
        transactionVotes[_n].approvals++;

        //require 70% approval votes from team members to debit a transaction amount
        if(transactionVotes[_n].approvals * 100 >= (teamMembers.length * 70)) {
            transactionNumber[_n].status = Status.Debited;
            totalCredits -= transactionNumber[_n].amount;
            
            //once debited, check remaining pending transaction amounts to make sure there are enough credits available
            for(uint i=1; i<= transactionCounter; i++) {
                if(transactionNumber[i].status == Status.Pending && transactionNumber[i].amount > totalCredits) {
                        transactionNumber[i].status = Status.Failed;
                }
            }
        }
    }

    //vote for rejecting a transaction amount
    function reject(uint256 _n) public onlyTeamMembers {
        require(_n <= transactionCounter && _n > 0, 'Invalid transaction number');
        require(hasVoted[_n][msg.sender] == false, 'You have already voted');
        require(transactionNumber[_n].status == Status.Pending, "Transaction has already been approved or has already been denied");

        //can only vote once
        hasVoted[_n][msg.sender] = true;
        transactionVotes[_n].denials++;

        //require 30% denial votes from team members to fail a transaction amount
        if(transactionVotes[_n].denials * 100 >= (teamMembers.length * 30)) {
            transactionNumber[_n].status = Status.Failed;
        }
    }

    //check remaing credits in the wallet
    function credits() public view onlyTeamMembers returns (uint256) {
        return totalCredits;
    }

    //check a specific transaction amount and status
    function viewTransaction(uint256 _n) public view onlyTeamMembers returns (uint amount, string memory status){
        require(_n <= transactionCounter, 'Invalid transaction number');

        string memory reportStatus;

        if(transactionNumber[_n].status == Status.Pending) {
            reportStatus = "pending";
        } else if (transactionNumber[_n].status == Status.Debited) {
            reportStatus = "debited";
        } else if (transactionNumber[_n].status == Status.Failed) {
            reportStatus = "failed";
        }

        return (transactionNumber[_n].amount, reportStatus);
    }
}