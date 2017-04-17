pragma solidity ^ 0.4 .0;

import "std.sol";

contract Bazar is owned {

    struct Product {
        string description;
        uint price;
        uint stock;
        uint idx;
    }
    mapping(uint => Product) products;
    uint[] private productsIndex;

    struct Order {
        address customer;
        uint productCode;
        uint quantity;
        uint pricePerUnit;
        bool fulfilled;
    }
    mapping (uint => Order) orders;
    uint[] private ordersIndex;

    uint private stockValue;
    uint private inFlightOrderValue;

    event ProductAdded(uint indexed productCode, uint idx, string description, uint price, uint stock);
    event ProductUpdated(uint indexed productCode, uint idx, string description, uint price, uint stock);
    event ProductDeleted(uint indexed productCode, uint idx);

    function isValidProduct(uint productCode) public constant
    returns(bool isValid) {
        if (productsIndex.length == 0) return false;
        return (productsIndex[products[productCode].idx] == productCode);
    }

function insertProduct(int productCode, string description, uint price, uint stock userEmail) public
    returns(uint index)
  {
    if(isValidProduct(productCode)) throw;
    products[productCode].description = description;
    products[productCode].price   = price;
    products[productCode].stock = stock;
    products[productCode].idx     = productsIndex.push(productCode)-1;
    stockValue += price * stock;
    ProductAdded(
        productCode,
        products[productCode].idx,
        description,
        price);
    return productsIndex.length-1;
  }

    function deleteProduct(uint productCode) public
    returns(uint idx) {
        if (!isValidProduct(productCode)) throw;

        //soft delete?
        uint idxProductToDelete = products[productCode].idx;
        uint productCodeToShift = productsIndex[productsIndex.length - 1];

        stockValue -= products[productCode].price * stock;

        productsIndex[idxProductToDelete] = productCodeToShift;
        products[productCodeToShift].idx = idxProductToDelete;

        productsIndex.length--;
        ProductDeleted(
            productCode,
            idxProductToDelete);
        ProductUpdated(
            productCodeToShift,
            idxProductToDelete,
            products[productCodeToShift].description,
            products[productCodeToShift].price,
            products[productCodeToShift].stock);
        return idxProductToDelete;
    }

    function getProduct(uint productCode) public constant
    returns(string description, uint price, uint stock, uint idx) {
        if (!isValidProduct(productCode)) throw;
        return (
            products[productCode].description,
            products[productCode].price,
            products[productCode].stock,
            products[productCode].idx);
    }

    function updateProductDescriptio(uint productCode, string description) public
    returns(bool success) {
        if (!isValidProduct(productCode)) throw;
        products[productCode].description = description;
        ProductUpdated(
            productCode,
            products[productCode].idx,
            products[productCode].description,
            products[productCode].price,
            products[productCode].stock);
        return true;
    }

    function updateProductPrice(uint productCode, uint price) public
    returns(bool success) {
        if (!isValidProduct(productCode)) throw;

        var beforeVal = products[productCode].price * products[productCode].stock;
        products[productCode].price = price;
        var afterVal = products[productCode].price * products[productCode].stock;
        stockValue += beforeVal - afterVal;

        ProductUpdated(
            productCode,
            products[productCode].idx,
            products[productCode].description,
            products[productCode].price,
            products[productCode].stock);
        return true;
    }

    function updateProductStock(uint productCode, uint stock) public
    returns(bool success) {
        if (!isValidProduct(productCode)) throw;

        var beforeVal = products[productCode].price * products[productCode].stock;
        products[productCode].stock = stock;
        var afterVal = products[productCode].price * products[productCode].stock;
        stockValue += beforeVal - afterVal;

        ProductUpdated(
            productCode,
            products[productCode].idx,
            products[productCode].description,
            products[productCode].price,
            products[productCode].stock);
        return true;
    }

    function getProductCount() public constant
    returns(uint count) {
        return productsIndex.length;
    }

    function getProductAtIndex(uint idx) public constant
    returns(uint productCode) {
        return productsIndex[idx];
    }

    function buyProduct(uint productCode, uint quantity) public payable returns(bool success) {

        if (!isValidProduct(productCode)) throw;

        //enough stock?
        if (products[productCode].stock < quantity) throw;

        //have they sent the correct price?
        var costOfSale = products[productCode].price * quantity;
        if (msg.value < costOfSale) throw;


        var beforeVal = products[productCode].price * products[productCode].stock;
        products[productCode].stock -= quantity;
        var afterVal = products[productCode].price * products[productCode].stock;
        stockValue += beforeVal - afterVal;

        //populate order


        return true;
    }

    function killMe() returns(bool) {

        //TODO - not allow if outstanding orders

        if (msg.sender == owner) {
            suicide(owner);
            return true;
        }
    }

    function() payable {
      throw;
    }
}
