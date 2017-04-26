pragma solidity ^ 0.4 .0;

//base bazar
// single owner
// no order processing

contract Bazar {


    address owner;
    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    struct Product {
        string description;
        uint price;
        uint stock;
        uint idx;
    }
    mapping(uint => Product) products;
    uint[] private productsIndex;

    uint private stockValue;

    event ProductAdded(uint indexed productCode, uint idx, string description, uint price, uint stock);
    event ProductUpdated(uint indexed productCode, uint idx, string description, uint price, uint stock);
    event ProductDeleted(uint indexed productCode, uint idx);

    function Bazar() {
        owner = msg.sender;
    }

    function isValidProduct(uint productCode)
    public
    constant
    returns(bool isValid) {
        if (productsIndex.length == 0) return false;
        return (productsIndex[products[productCode].idx] == productCode);
    }

    function insertProduct(uint productCode, string description, uint price, uint stock)
    onlyOwner
    returns(uint index) {
        if (isValidProduct(productCode)) throw;
        products[productCode].description = description;
        products[productCode].price = price;
        products[productCode].stock = stock;
        products[productCode].idx = productsIndex.push(productCode) - 1;
        stockValue += price * stock;
        ProductAdded(
            productCode,
            products[productCode].idx,
            description,
            price,
            stock);
        return productsIndex.length - 1;
    }

    function deleteProduct(uint productCode)
    onlyOwner
    public
    returns(uint idx) {
        if (!isValidProduct(productCode)) throw;

        //soft delete?
        uint idxProductToDelete = products[productCode].idx;
        uint productCodeToShift = productsIndex[productsIndex.length - 1];

        stockValue -= products[productCode].price * products[productCode].stock;

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

    function getProduct(uint productCode)
    public
    constant
    returns(string description, uint price, uint stock, uint idx) {
        if (!isValidProduct(productCode)) throw;
        return (
            products[productCode].description,
            products[productCode].price,
            products[productCode].stock,
            products[productCode].idx);
    }

    function updateProductDescription(uint productCode, string description)
    onlyOwner
    public
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

    function updateProductStock(uint productCode, uint stock)
    public
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

        return true;
    }


    function makePayment() onlyOwner payable {}

    function makeWithdrawl(uint amount) onlyOwner {

        if (this.balance < amount) throw;

        if (!msg.sender.send(amount)) throw;
    }


    function killMe() returns(bool) {

        if (msg.sender == owner) {
            suicide(owner);
            return true;
        }
    }


    //do not allow eth to be sent
    function() payable {
        throw;
    }
}
