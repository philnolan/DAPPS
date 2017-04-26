var Bazar = artifacts.require("./Bazar.sol");

contract('Bazar', function(accounts) {
    var bazar;

    var productCode = 123,
        description = "test product",
        price = 1,
        stock = 10;

    it("should allow valid product to be created", function() {
        return Bazar.deployed().then(function(instance) {
            bazar = instance;
            return bazar.insertProduct.sendTransaction(productCode, description, price, stock, {
                from: accounts[0]
            });
        }).then(function(result) {
            return bazar.getProductCount.call({
                from: accounts[0]
            });
        }).then(function(result) {
            assert.equal(result, 1, "should be one for product count");
            return bazar.getProductAtIndex.call(0,{
                from: accounts[0]
            });
        }).then(function(result) {
            assert.equal(result, productCode, "should be " + productCode + "  for product code");
            return bazar.getProduct.call(productCode, {
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
