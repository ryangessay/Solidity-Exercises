// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShipmentService {

    address owner;
    enum OrderState { NoOrdersPlaced, OrderShipped, Delivered }
    
    struct Order {
        uint pin;
        OrderState state;
    }
    
    mapping (address => Order[]) customerOrders;
    mapping (address => uint) shippedOrders;
    mapping (address => uint) completedOrders;

    constructor() {owner = msg.sender;}

    modifier onlyOwner() {
        require(msg.sender==owner, "Only the owner can use this function");
         _;
    } 

    //This function inititates the shipment
    function shipWithPin(address _customerAddress, uint _pin) public onlyOwner {
        require(_customerAddress != owner, "Address entered is owner address");
        require(_pin > 999 && _pin < 10_000, "Pin number must be between 999 and 10,000");

        customerOrders[_customerAddress].push(Order(_pin, OrderState.OrderShipped));
        shippedOrders[_customerAddress]++;
    }


    //This function acknowlegdes the acceptance of the delivery
    function acceptOrder(uint _pin) public {
        require(msg.sender != owner, "Only customers can use this function");
        require(_pin > 999 && _pin < 10_000, "Pin number must be between 999 and 10,000");

        for (uint i=0; i<customerOrders[msg.sender].length; i++) {
            if(customerOrders[msg.sender][i].pin == _pin) {
                customerOrders[msg.sender][i].state = OrderState.Delivered;
                
                completedOrders[msg.sender]++;
                shippedOrders[msg.sender]--;
                return;
            }
        }
        revert("No matching order found");
    }

    //This function outputs the status of the delivery
    function checkStatus(address _customerAddress) public view returns (uint) {
        require(msg.sender == _customerAddress || msg.sender == owner, "Address entered must be your own address or you must be the owner");

        if (shippedOrders[_customerAddress] > 0) {
            return shippedOrders[_customerAddress];
        } else {
            return 0;
        }
    }

    //This function outputs the total number of successful deliveries
    function totalCompletedDeliveries(address _customerAddress) public view returns (uint) {
        require(msg.sender == owner || msg.sender == _customerAddress, "You must be either the owner or an existing customer");

        return completedOrders[_customerAddress];
    }
}