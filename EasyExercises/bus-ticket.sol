// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TicketBooking {

    uint[] seatNumbers = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
    uint[] showAvailable;
    mapping (uint => bool) seatAvailable;
    mapping (address => uint[]) purchasedTickets;

    //set all seatNumbers to available=true when the contract is deployed
    constructor() {
        for(uint i=0; i<seatNumbers.length; i++)
            {seatAvailable[seatNumbers[i]] = true;}
    }

    //book seats by seat number
    function bookSeats(uint[] memory _seatNumbers) public {
        require(_seatNumbers.length > 0 && _seatNumbers.length <= 4, 'You can only reserve 1 to 4 seats.');
        require((purchasedTickets[msg.sender].length + _seatNumbers.length) <= 4, 'You cannot reserve more than 4 seats.');
        
        uint[] storage purchases = purchasedTickets[msg.sender];

        for(uint i=0; i<_seatNumbers.length; i++) {
            require(seatAvailable[_seatNumbers[i]] == true, 'Seat is unavailable!');

            seatAvailable[_seatNumbers[i]] = false;
            purchases.push(_seatNumbers[i]);
        }

        purchasedTickets[msg.sender] = purchases;
    }
    
    //show available seats
    function showAvailableSeats() public returns (uint[] memory) {
        
        delete showAvailable;

        for(uint i=0; i<seatNumbers.length; i++) {
            if(seatAvailable[seatNumbers[i]] == true) {
                showAvailable.push(seatNumbers[i]);
            }
        }
        return showAvailable;
    }
    
    //check a specific seat for it's availability
    function checkAvailability(uint seatNumber) public view returns (bool) {
        require(seatNumber >= 1 && seatNumber <= 20, 'Seat number must be between 1 and 20');
        if(seatAvailable[seatNumber] == true) {
            return true;
        } else {
            return false;
        }
    }
    
    //check msg.sender's purchased tickets
    function myTickets() public view returns (uint[] memory) {
        return purchasedTickets[msg.sender];
    }
}
