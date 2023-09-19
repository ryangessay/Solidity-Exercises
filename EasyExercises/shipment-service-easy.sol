// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShipmentService {

    address owner;
    enum OrderState { NoOrdersPlaced, OrderShipped, Delivered }
    
    struct Order {
        uint pin;
        OrderState state;
    }
    
    mapping (address => Order) customerOrders;
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
        require(customerOrders[_customerAddress].state != OrderState.OrderShipped,"Customer already has an order that has yet to be delivered");

        customerOrders[_customerAddress] = Order(_pin, OrderState.OrderShipped);
    }


    //This function acknowlegdes the acceptance of the delivery
    function acceptOrder(uint _pin) public {
        require(msg.sender != owner, "Only customers can use this function");
        require(_pin > 999 && _pin < 10_000, "Pin number must be between 999 and 10,000");
        require(customerOrders[msg.sender].pin == _pin, "Pin number does not match");

            customerOrders[msg.sender] = Order(_pin, OrderState.Delivered);
            completedOrders[msg.sender]++;
    }

    //This function outputs the status of the delivery
    function checkStatus(address _customerAddress) public view returns (string memory) {
        require(msg.sender == owner || msg.sender == _customerAddress, "You must be either the owner or an existing customer");

        if (customerOrders[_customerAddress].state == OrderState.NoOrdersPlaced) {
            return "no orders placed";
        } else if (customerOrders[_customerAddress].state == OrderState.OrderShipped) {
            return "shipped";
        } else if (customerOrders[_customerAddress].state == OrderState.Delivered) {
            return "delivered";
        } else {
            return "Invalid order status";
        }
    }

    //This function outputs the total number of successful deliveries
    function totalCompletedDeliveries(address _customerAddress) public view returns (uint) {
        require(msg.sender == owner || msg.sender == _customerAddress, "You must be either the owner or an existing customer");

        return completedOrders[_customerAddress];
    }
}