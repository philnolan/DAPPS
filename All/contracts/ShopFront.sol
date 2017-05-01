pragma solidity ^ 0.4 .0;

contract ShopFront {

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

    address public shopOwner;

    struct Product {
        uint price;
        uint stock;
        uint idx;
    }
    mapping(uint => Product) products;
    uint[] productsIndex;

    modifier onlyShopOwner() {
        if (msg.sender != shopOwner) throw;
        _;
    }

    event LogProductAdded(uint id, uint price, uint stock);
    event LogProductBought(address buyer, uint id, uint price, uint quantity);

    function ShopOwner() {
        shopOwner = msg.sender;
    }

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
    function addProduct(uint _id, uint _price, uint _stock)
    onlyShopOwner
    returns(bool success) {
        if (isValidProduct(_id)) return false;

        products[_id] = Product({
            price: _price,
            stock: _stock,
            idx: productsIndex.push(_id) - 1});

        LogProductAdded(_id,
            _price,
            _stock);
        return true;
    }

    //buy function - only allows 1 product for now
    function buyProduct(uint _id)
    payable
    returns(bool success) {

        if (products[_id].stock < 1) throw;
        uint price = products[_id].price;
        if (msg.value < price) throw;

        LogProductBought(msg.sender, _id,  price, 1);
        return true;
    }

    function getProductCount()
    constant
    returns(uint count) {
        return productsIndex.length;
    }

    function makePayment()
    onlyShopOwner
    payable {}

    function makeWithdrawl(uint _amount)
    onlyShopOwner {
        if (this.balance < _amount) throw;

        if (!msg.sender.send(_amount)) throw;
    }
}
