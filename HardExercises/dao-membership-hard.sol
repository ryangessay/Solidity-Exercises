// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOMembership {

    address owner;
    uint256 memberCount;

    mapping(address => bool) member;
    mapping(address => bool) sentEntry;
    mapping(address => uint) approvedVotes;
    mapping(address => uint) disapprovedVotes;
    mapping(address => uint) removeMemberVotes;
    mapping(address => bool) ineligible;
    mapping(address => mapping(address => bool)) hasVoted;
    mapping(address => mapping(address => bool)) votedForRemoval;

    constructor() {owner = msg.sender; memberCount++; member[owner] = true;}

    modifier restricted() {
        require(memberCount > 0, "no members, contract is now restriced");
         _;
    }


    //To apply for membership of DAO
    function applyForEntry() public restricted {
        require(member[msg.sender] == false, "you are already a member");
        require(sentEntry[msg.sender] == false, "you can only apply once");

        sentEntry[msg.sender] = true;
    }
    
    //To approve the applicant for membership of DAO
    function approveEntry(address _applicant) public restricted {
        require(member[msg.sender] == true, "must be a member");
        require(sentEntry[_applicant] == true, "applicant not found");
        require(member[_applicant] == false, "applicant is already a member");
        require(hasVoted[msg.sender][_applicant] == false, "you have already voted for this applicant");
        require(ineligible[_applicant] == false, "applicant has been disapproved entry");

        approvedVotes[_applicant]++;
        hasVoted[msg.sender][_applicant] = true;

        if(approvedVotes[_applicant] * 100 / (memberCount) >= 30) {
            member[_applicant] = true;
            memberCount++;
        }

    }

    //To disapprove the applicant for membership of DAO
    function disapproveEntry(address _applicant) public restricted {
        require(member[msg.sender] == true, "must be a member");
        require(sentEntry[_applicant] == true, "applicant not found");
        require(member[_applicant] == false, "applicant is already a member");
        require(hasVoted[msg.sender][_applicant] == false, "you have already voted for this applicant");

        disapprovedVotes[_applicant]++;
        hasVoted[msg.sender][_applicant] = true;

        if(disapprovedVotes[_applicant] * 100 / (memberCount) >= 70) {
            ineligible[_applicant] = true;
        }

    }

    //To remove a member from DAO
    function removeMember(address _memberToRemove) public restricted {
        require(member[msg.sender] == true, "must be a member");
        require(msg.sender != _memberToRemove, "you cannot remove yourself");
        require(ineligible[_memberToRemove] == false, "address entered is not a member");

        removeMemberVotes[_memberToRemove]++;
        votedForRemoval[msg.sender][_memberToRemove] = true;

        if(removeMemberVotes[_memberToRemove] * 100 / (memberCount-1) >= 70) {
            ineligible[_memberToRemove] = true;
            member[_memberToRemove] = false;
            memberCount--;
        }
    }

    //To leave DAO
    function leave() public restricted {
        require(member[msg.sender] == true, "must be a member");
        member[msg.sender] = false;
        memberCount--;

    }

    //To check membership of DAO
    function isMember(address _user) public restricted view returns (bool) {
        require(member[msg.sender] == true, "must be a member");
        
        return member[_user];
    }

    //To check total number of members of the DAO
    function totalMembers() public restricted view returns (uint256) {
        if(member[msg.sender] == true) {
            return memberCount;
        } else {
            revert("you must be a member to run this function");
        }
    }
}
