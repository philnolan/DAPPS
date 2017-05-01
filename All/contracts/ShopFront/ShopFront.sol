pragma solidity ^0.4.0;

import "../Owned.sol";
import "./Products.sol";
contract ShopFront is Owned, Products {

    //wk5. A SHOPFRONT
    //The project will start as a database whereby:
    //as an administrator, you can add products, which consist of an id, a price and a stock.
    //as a regular user you can buy 1 of the products.
    //as the owner you can make payments or withdraw value from the contract.
    //Eventually, you will refactor it to include:
    //ability to remove products.
    //co-purchase by different people.
    //add merchants akin to what Amazon has become.
    //add the ability to pay with a third-party token.

    //Products.sol

    event LogProductAdded(uint id, uint price, uint stock);
    event LogProductBought(address buyer, uint id, uint quantity);

    function ShopOwner() {
    }


    //adds a product if not already exists
    function addProduct(uint _id, uint _price, uint _stock)
    onlyOwner
    returns(bool success) {

        if(! add(_id, _price,_stock)) return false;

        LogProductAdded(_id,
            _price,
            _stock);

        return true;
    }

    //buy function - only allows 1 product for now
    function buyProduct(uint _id)
    payable
    returns(bool success) {

        if (!okToBuy(_id, msg.value)) throw;

        LogProductBought(msg.sender, _id, 1);
        return true;
    }


    function makePayment()
    onlyOwner
    payable {}

    function makeWithdrawl(uint _amount)
    onlyOwner
    {
        if (this.balance < _amount) throw;

        if (!msg.sender.send(_amount)) throw;
    }
}
