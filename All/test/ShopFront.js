const ShopFront = artifacts.require("./ShopFront.sol");

web3.eth.getTransactionReceiptMined = function(txnHash, interval) {
    var transactionReceiptAsync;
    interval = interval ? interval : 500;
    transactionReceiptAsync = function(txnHash, resolve, reject) {
        try {
            var receipt = web3.eth.getTransactionReceipt(txnHash);
            if (receipt == null) {
                setTimeout(function() {
                    transactionReceiptAsync(txnHash, resolve, reject);
                }, interval);
            } else {
                resolve(receipt);
            }
        } catch (e) {
            reject(e);
        }
    };

    return new Promise(function(resolve, reject) {
        transactionReceiptAsync(txnHash, resolve, reject);
    });
};


contract('ShopFront', function(accounts) {

    //return ShopFront.deployed().then(function(instance) {
    //    splitter = instance;

    //should only allow shopOwner to add product

    it("should start with zero products", () => {
        var instance;
        return ShopFront.deployed()
            .then(_instance => {
                instance = _instance;
                return instance.getProductCount.call();
            })
            .then(result => {
                assert.equal(result, 0, "failed to start with zero products");
            });
    });

    it("should allow add of a product", function() {
        var instance;
        return ShopFront.deployed()
            .then(_instance => {
                instance = _instance;
                return instance.addProduct.call(1, 10, 10, {
                    from: accounts[0]
                });
            })
            .then(function(result) {
                assert.isTrue(result, "should be true");
                return instance.addProduct(1, 10, 1, {
                    from: accounts[0]
                });
            })
            .then(function(tx) {
                return web3.eth.getTransactionReceiptMined(tx);

            })
            .then (function(receipt) {
              console.log(receipt);
            });
    });
});
