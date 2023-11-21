// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Holi {

    uint totalMoney = 100;
    string red;
    string blue;
    string green;

    mapping(string => uint) public colorAmount;

    constructor() {
    colorAmount["red"] = 40;
    colorAmount["blue"] = 40;
    colorAmount["green"] = 30;
    }

    // this function is used to buy the desired colour
    function buyColour(string memory colour, uint price) public {

    if (keccak256(abi.encodePacked(colour)) == keccak256(abi.encodePacked("red"))) {
        require(colorAmount["red"] >= price, "Cannot purchase more than is available");
        colorAmount["red"] -= price;
        totalMoney -= price;
    } else if (keccak256(abi.encodePacked(colour)) == keccak256(abi.encodePacked("blue"))) {
        require(colorAmount["blue"] >= price, "Cannot purchase more than is available");
        colorAmount["blue"] -= price;
        totalMoney -= price;
    } else if (keccak256(abi.encodePacked(colour)) == keccak256(abi.encodePacked("green"))) {
        require(colorAmount["green"] >= price, "Cannot purchase more than is available");
        colorAmount["green"] -= price;
        totalMoney -= price;
    } else {
        revert("Invalid colour selection");
        }
    }

    //this functions will return credit balance
    function credits() public view returns(uint n) {
        require(totalMoney >= 0 && totalMoney <= 100, "Not enough credits");
        return totalMoney;
    }

}