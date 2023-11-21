// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ScholarshipCreditContract {

    address owner;
    uint totalCredits = 1_000_000;

    struct CategoryFunds {
        uint credits;
        string category;
    }

    mapping(address => bool) available;
    mapping(address => bool) merchant;
    mapping(address => bool) scholar;

    mapping(address => string) merchantOrStudent;
    mapping(address => mapping(string => uint)) scholarship;

    constructor() {owner=msg.sender;}

    // modifier for only owner functions
    modifier onlyOwner() {
        require(msg.sender==owner, "Only the owner can use this");
         _;
    }

    // modifier to check the category
    modifier validCategory (string calldata _category) {
        require(
            keccak256(abi.encodePacked(_category)) == keccak256(abi.encodePacked("meal")) ||
            keccak256(abi.encodePacked(_category)) == keccak256(abi.encodePacked("academics")) ||
            keccak256(abi.encodePacked(_category)) == keccak256(abi.encodePacked("sports")) ||
            keccak256(abi.encodePacked(_category)) == keccak256(abi.encodePacked("all")),
            "Invalid category: must be meal, academics, sports, or all");
        _;
    }
    

    //This function assigns credits of particular category to student getting the scholarship
    function grantScholarship(address _studentAddress, uint _credits, string calldata _category) public payable onlyOwner validCategory(_category){
        require(_credits > 0 && totalCredits >= _credits, "Invalid credits amount");
        require(_studentAddress != owner, "Cannot send to owner");

        //check to see if address is a merchant
        if(merchant[_studentAddress] == true) {

            //check to see if address is unregistered
            if(available[_studentAddress] == false) {
                revert("Merchant is unregistered");
            }  

            //send funds to merchant that is available  
            if(keccak256(abi.encodePacked(_category)) == keccak256(abi.encodePacked("all"))) {
            //scholarship[_studentAddress] = CategoryFunds(_credits, _category);
            scholarship[_studentAddress]["all"] += _credits;
            } else {
                revert("Category must be all");
            }

        //if not a merchant, send to scholar
        } else {
            //scholarship[_studentAddress] = CategoryFunds(_credits, _category);
            scholarship[_studentAddress][_category] += _credits;
            scholar[_studentAddress] = true;
            }
        totalCredits -= _credits;
    }


    //This function is used to register a new merchant under given category
    function registerMerchantAddress(address _merchantAddress, string calldata _category) public onlyOwner {
        require(scholar[_merchantAddress] == false, "Address matches a scholar's address");
        require(keccak256(abi.encodePacked(_category)) == keccak256(abi.encodePacked("meal")) ||
            keccak256(abi.encodePacked(_category)) == keccak256(abi.encodePacked("academics")) ||
            keccak256(abi.encodePacked(_category)) == keccak256(abi.encodePacked("sports")),
            "Invalid category: must be meal, academics, sports");
        
        //scholarship[_merchantAddress] = CategoryFunds(0, _category);
        scholarship[_merchantAddress][_category];

        merchant[_merchantAddress] = true;
        available[_merchantAddress] = true;
    }


    //This function is used to deregister an existing merchant
    function deregisterMerchantAddress(address _merchantAddress) public onlyOwner {
        require(scholar[_merchantAddress] == false, "Cannot deregister a scholar's address");
        require(_merchantAddress != owner, "Cannot deregister owner's address");
        require(merchant[_merchantAddress] == true, "Cannot deregister an address that does not exist");
       
        available[_merchantAddress] = false;

        //need to write some code to send funds back to totalCredits
    }


    //This function is used to revoke the scholarship of a student
    function revokeScholarship(address _studentAddress) public onlyOwner{
        require(scholar[_studentAddress] == true);

        //uint _studentCredits = scholarship[_studentAddress].credits;
        uint tempCredits = scholarship[_studentAddress]["meal"] + scholarship[_studentAddress]["academics"] + scholarship[_studentAddress]["sports"];

        totalCredits += tempCredits;
        scholar[_studentAddress] == false;

    }

    //Students can use this function to transfer credits only to registered merchants
    function spend(address _merchantAddress, uint _amount) public {
        require(scholar[msg.sender] == true, "Not a scholarship member");
        require(merchant[_merchantAddress] == true, "Invalid merchant address");
        //require(scholarship[msg.sender].credits >= _amount, "Insufficient credits");
       
       
       if (CategoryFunds[msg.sender].category == CategoryFunds[_merchantAddress].category) {

       }
        
        //will need to create a new function that gets the merchant's "all" category amount
        scholarship[_merchantAddress]["all"] += _amount;

        scholarship[msg.sender].credits -= _amount;

    }
    //This function is used to check the funds of the merchant's "all" category
    function checkMerchantBalance(address _merchantAddress)  internal view returns (uint) {

        CategoryFunds memory _funds = scholarship[_merchantAddress];

        //need to create a global variable to hold the amount here
        //will also need to clear that "temp" variable amount within spending function
        if (keccak256(bytes(_funds.category)) == keccak256(bytes("all"))) {
            return _funds.credits;
        } else {
            return 0;
        }

    }
    //This function is used to see the available credits assigned.
    function checkBalance(string calldata _category) public view returns (uint) {
        require((scholar[msg.sender] == true) || (merchant[msg.sender] == true) || (msg.sender == owner));

       // CategoryFunds memory _funds = scholarship[msg.sender];

        if (merchant[msg.sender] == true) {
            return scholarship[msg.sender][_category];
        } else if (scholar[msg.sender] == true) {
            return scholarship[msg.sender][_category];
        } else if (msg.sender == owner && keccak256(bytes(_category)) == keccak256(bytes("all"))) {
            return totalCredits;
        } else {
            return 0;
        }
    }

    //This function is used to see the category under which Merchants are registered
    function showCategory() public view returns (string memory) {
        require(merchant[msg.sender] == true && available[msg.sender] == true, "Invalid merchant address");

        return scholarship[msg.sender].category;
    }
}