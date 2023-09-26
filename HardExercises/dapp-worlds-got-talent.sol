// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DWGotTalent {

    address owner;
    address[] judges;
    address[] finalists;
    address[] winners;

    uint judgeWeightage;
    uint audienceWeightage;

    bool votingLive;
    bool votingEnd;

    mapping (address => bool) isJudge;
    mapping (address => bool) isFinalist;

    mapping (address => uint) judgeVote;
    mapping (address => uint) audienceVote;
    mapping (address => address) votedFor;
    mapping (address => bool) hasVoted;
    
    constructor() {owner = msg.sender;}

    //Modifier that allows only the contract owner to run.
    modifier onlyOwner() {
        require(owner == msg.sender, "You must be the owner to run this function");
        _;
    }

    //Modifier that demands judges, finalists and weightage be set before vote can be started.
    modifier beforeVote() {
        require(judges.length > 0, "Please submit at least one judge");
        require(finalists.length > 0, "Please submit at least one finalist");
        require(judgeWeightage > 0 || audienceWeightage > 0, "Either judge weightage or audience weightage must be greater than zero");
        _;
    }
    
    //Modifier to prevent changes to every function other than castVote and endVote while voting is live.
    modifier liveVote() {
        require(!votingLive, "Vote is live, cannot edit Judges, Finalists or Weightage");
        _;
    }

    //Modifier to prevent all functions from being executed other than showResult.
    modifier endVote() {
        require(!votingEnd, "Vote has ended");
        _;
    }


    //Defines the addresses for the judges.
    function selectJudges(address[] memory _arrayOfAddresses) public onlyOwner liveVote endVote {
        require(_arrayOfAddresses.length > 0, "You must enter in at least 1 judge address");
        
        //Check to see that addresses entered are not the owner or finalists.
        for (uint i=0; i<_arrayOfAddresses.length; i++) {
            require(_arrayOfAddresses[i] != owner, "Address entered cannot be the Owner");
            require(!isFinalist[_arrayOfAddresses[i]], "Address entered cannot be a Finalist");
        }
        //Set addresses entered to be judges.
        for (uint i=0; i<_arrayOfAddresses.length; i++) {
            judges.push(_arrayOfAddresses[i]);
            isJudge[_arrayOfAddresses[i]] = true;
        }
    }

    //Defines the weightage for judges and audiences.
    function inputWeightage(uint _judgeWeightage, uint _audienceWeightage) public onlyOwner liveVote endVote {
        require(_judgeWeightage >= 0 || _audienceWeightage >= 0, "Weightage must be greater than zero");

        judgeWeightage = _judgeWeightage;
        audienceWeightage = _audienceWeightage;
    }

    //Defines the addresses for the finalists.
    function selectFinalists(address[] memory _arrayOfAddresses) public onlyOwner liveVote endVote {
        require(_arrayOfAddresses.length > 0, "You must enter in at least 1 finalist address");

        //Check to see that addresses entered are not the owner or judges.
        for (uint i=0; i<_arrayOfAddresses.length; i++) {
            require(_arrayOfAddresses[i] != owner, "Address entered cannot be the Owner");
            require(!isJudge[_arrayOfAddresses[i]], "Address entered cannot be a Judge");
        }
        //Set addresses entered to be finalists.
        for (uint i=0; i<_arrayOfAddresses.length; i++) {
            finalists.push(_arrayOfAddresses[i]);
            isFinalist[_arrayOfAddresses[i]] = true;
        }
    }

    //Starts the voting process.
    function startVoting() public onlyOwner beforeVote endVote {
        votingLive = true;
    }

    //Voting for a finalist. 
    function castVote(address _finalistAddress) public beforeVote endVote {
        require(isFinalist[_finalistAddress], "Address entered is not a Finalist");
        
        //Checks to see if they have already voted and writes down the address they voted for
        address lastVote = votedFor[msg.sender];
        require(lastVote != _finalistAddress, "You have already voted for this finalist");

        //If the msg.sender has voted, the last vote is subtracted and the new vote is counted.
        //Check to see if msg.sender is a judge or an audience member and appropriately assign the vote.
        if (hasVoted[msg.sender]) { 
            if (isJudge[msg.sender]) {
                judgeVote[lastVote]--;
                judgeVote[_finalistAddress]++; 
                votedFor[msg.sender] =_finalistAddress;
            } else {
                audienceVote[lastVote]--;
                audienceVote[_finalistAddress]++;
                votedFor[msg.sender] =_finalistAddress;
            }    
        }   

        if (isJudge[msg.sender]) {
            judgeVote[_finalistAddress]++; 
            votedFor[msg.sender] =_finalistAddress;
            hasVoted[msg.sender] = true;
        } else {
            audienceVote[_finalistAddress]++;
            votedFor[msg.sender] =_finalistAddress;
            hasVoted[msg.sender] = true;
        }            
    }

    //Ends the voting process.
    function endVoting() public onlyOwner beforeVote endVote {
        require(votingLive, "Vote has not started yet");
        
        //Sets votingLive back to false and endVote to true.
        votingLive = false;
        
        //Determines the highest score or scores if two finalists should tie.
        uint _highScore;

        for (uint i=0; i<finalists.length; i++) {
            
            uint total = (judgeVote[finalists[i]] * judgeWeightage) + (audienceVote[finalists[i]] * audienceWeightage);
            
            if(total > _highScore) {
                winners = [finalists[i]];
                _highScore = total;
            } else if (total == _highScore) {
                winners.push(finalists[i]);
            }
        }

        votingEnd = true;
    }

    //Returns the winners. 
    function showResult() public view beforeVote liveVote returns (address[] memory) {
        require(votingEnd, "Voting has not ended");
        return winners;
    }

}