pragma solidity ^0.4.4;

contract Products {

    struct Product {
        uint price;
        uint stock;
        uint idx;
    }
    mapping(uint => Product) products;
    uint[] private productsIndex;

    //checks whether the passed product id exists within the products array
    function isValidProduct(uint _id)
    internal
    constant
    returns(bool isValid) {
        if (productsIndex.length == 0) return false;
        uint idx = products[_id].idx;
        return (productsIndex[idx] == _id);
    }

    //adds a product if not already exists
    function add(uint _id, uint _price, uint _stock)
    internal
    returns(bool success) {
        if (isValidProduct(_id)) return false;

        products[_id] = Product({
            price: _price,
            stock: _stock,
            idx: productsIndex.push(_id) - 1
        });

        return true;
    }

    //buy function - only allows 1 product for now
    function okToBuy(uint _id, uint value)
    internal
    returns(bool success) {

        if (products[_id].stock < 1) return false;
        if (value < products[_id].price) return false;

        return true;
    }


    function getProductCount()
    constant
    returns(uint count) {
        return productsIndex.length;
    }

}
