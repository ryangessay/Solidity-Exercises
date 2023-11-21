pragma solidity ^0.8.16;

contract Kata {
  function solution(uint n) public pure returns (string memory) {
    require(n >= 1 && n <= 3999, "Number must be between 1 to 3999");

    string[4] memory thousand = ["", "M", "MM", "MMM"];
    string[10] memory hundred = ["", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"];
    string[10] memory ten = ["", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"];
    string[10] memory one = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"];

    string memory romanThousand = thousand[n/1000];
    string memory romanHundred = hundred[n%1000 /100];
    string memory romanTen = ten[((n%1000) % 100) / 10];
    string memory romanOne = one[(((n%1000) % 100) % 10) / 1];

    string memory result = string(abi.encodePacked(romanThousand, romanHundred, romanTen, romanOne));

    return result;
  }
}