web3.eth.getTransactionReceiptMined = function (txnHash, interval) {
  var transactionReceiptAsync;
  interval = interval ? interval : 500;
  transactionReceiptAsync = function(txnHash, resolve, reject) {
    try {
      var receipt = web3.eth.getTransactionReceipt(txnHash);
      if (receipt == null) {
        setTimeout(function () {
          transactionReceiptAsync(txnHash, resolve, reject);
        }, interval);
      } else {
        resolve(receipt);
      }
    } catch(e) {
      reject(e);
    }
  };

  return new Promise(function (resolve, reject) {
      transactionReceiptAsync(txnHash, resolve, reject);
  });
};


contract('ShopFront', function(accounts) {

    it("should start with zero products", function() {
        var shopFront = ShopFront.deployed();

        return shopFront.getProductCount.call()
            .then(function(result) {
                assert.equal(result.valueOf(), 0, "should be zero product count");
            });
    });

    it("should allow add of a product", function() {
        var shopFront = ShopFront.deployed();

        return shopFront.addProduct.call(1, 10, 1, {from: accounts[0]}  )
            .then(function(result) {
                assert.isTrue(result, "should be true");
            });
    });



});
