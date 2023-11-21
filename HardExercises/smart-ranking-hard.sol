// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SmartRanking {

    uint totalMarks;
    uint[] rollNumber;
    uint[] marks;

    constructor() {rollNumber.push(0); marks.push(0);}

    //this function insterts the roll number and corresponding marks of a student
    function insertMarks(uint _rollNumber, uint _marks) public {
        require(_marks >= 0 && _marks <= 100, "Mark must be 0 to 100");
        rollNumber.push(_rollNumber);
        marks.push(_marks);
        totalMarks++;
    }

    //this function returns the marks obtained by the student as per the rank
    function scoreByRank(uint _rank) public view returns(uint) {
        require(_rank > 0 && _rank <= totalMarks, "Rank number does not exist");
        
        uint[] memory orderedMarks = new uint[](marks.length);
        
        //input marks to orderedMarks
        for(uint i=0; i<marks.length; i++) {
            orderedMarks[i] = marks[i];  
        }
        //sort the array in descending order
        for(uint i=0; i<orderedMarks.length -1; i++) {
            for(uint j=i+1; j<orderedMarks.length; j++) {
                if(orderedMarks[i] < orderedMarks[j]) {
                    uint temp = orderedMarks[i];
                    orderedMarks[i] = orderedMarks[j];
                    orderedMarks[j] = temp;
                }
            }
        }

        return orderedMarks[_rank-1];
    }

    //this function returns the roll number of a student as per the rank
    function rollNumberByRank(uint _rank) public view returns(uint) {
        
        uint score = scoreByRank(_rank);
        uint finalRoleNumber;
        
        for(uint i=0; i<marks.length; i++) {
            if(score == marks[i]) {
                marks[i] == rollNumber[i];
                finalRoleNumber = rollNumber[i];
            }
        }

        return finalRoleNumber;

    }

}