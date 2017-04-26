var ShopKeeper = artifacts.require("./ShopKeeper.sol");


contract('ShopKeeper', function(accounts) {
    var shopKeeper;

    var productCode = 123,
        description = "test product",
        price = 1,
        stock = 10;

    before("should prepare", function() {
        alice = accounts[0];
        bob = accounts[1];
        carol = accounts[2];
        return ShopKeeper.deployed().then(function(instance) {
            shopKeeper = instance;
        });


//        Promise.promisifyAll(web3.eth, { suffix: "Promise" });
    });


    //it("should create base address as master merchant upon creation ", function() {
    //it("should allow valid new address to create merchant with waiting status", function() {
    //it("should allow master keeper to Reject merchant", function() {
    //it("should allow master keeper to Authroise merchant", function() {
    //it("should allow merchant to add product", function() {
    //it("should not allow non authorised merchant to add product", function() {


    it("should allow valid product to be created", function() {
console.log(shopKeeper);

        //return ShopKeeper.deployed().then(function(instance) {
        //    shopKeeper = instance;
        return shopKeeper.insertProduct.sendTransaction(productCode, description, price, stock, {
            from: accounts[0]
            //});
        }).then(function(result) {
            return shopKeeper.getProductCount.call({
                from: accounts[0]
            });
        }).then(function(result) {
            assert.equal(result, 1, "should be one for product count");
            return shopKeeper.getProductAtIndex.call(0, {
                from: accounts[0]
            });
        }).then(function(result) {
            assert.equal(result, productCode, "should be " + productCode + "  for product code");
            return shopKeeper.getProduct.call(productCode, {
                from: accounts[0]
            });
        }).then(function(result) {
            assert.equal(result[0], description, "should be " + description + "  for product description");
            assert.equal(result[1], price, "should be " + price + "  for product price");
            assert.equal(result[2], stock, "should be " + description + "  for product stock");
            assert.equal(result[3], 0, "should be 1 for product index");
        });
    });
});
