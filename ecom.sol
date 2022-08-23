// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 < 0.9.0;

contract Ecommerce{

    struct Product{
        string title;
        string desc;
        uint price;
        address payable seller;
        address buyer;
        uint productId;
        bool delivered;
    }

    Product[] public products;
    uint counter = 1;
    address payable public manager;

    bool destroyed = false;

    modifier isNotDestroyed{
        require(!destroyed , "Contract does not exist");
        _;
    }

    constructor(){
        manager=payable(msg.sender);
    }

    event registered(string title , uint productId , address seller);
    event bought(uint productId , address buyer);
    event delivered(uint productId);

    function SellYourProduct(string memory _title , string memory _desc , uint _price) public isNotDestroyed {

        Product memory tempProduct; 

        require(_price>0,"Price should be greater than zero");
        tempProduct.title = _title;
        tempProduct.desc = _desc;
        tempProduct.price = _price*10**18;
        tempProduct.seller = payable(msg.sender);
        tempProduct.productId = counter;
        products.push(tempProduct);
        counter++;
        emit registered(_title , tempProduct.productId , msg.sender);
    }

    function buyTheProduct(uint _productId) payable public isNotDestroyed{
        require(products[_productId-1].price == msg.value , "Please enter the exact price");
        require(products[_productId-1].seller != msg.sender , "Seller should not be the buyer");
        products[_productId-1].buyer = msg.sender;
        emit bought(_productId , msg.sender);
    }

    function delivery(uint _productId) public isNotDestroyed{
       require( products[_productId-1].buyer == msg.sender , "Onlly the buyer can confirm");
       products[_productId-1].delivered = true;
       products[_productId - 1].seller.transfer(products[_productId - 1].price);
       emit delivered(_productId);

    }

    function destroy() public isNotDestroyed{
        require(manager==msg.sender);
        manager.transfer(address(this).balance);
        destroyed = true;
    }

    fallback() payable external{
        payable(msg.sender).transfer(msg.value);
    }

}
