
//console.log(web3);
//console.log(web3.blockNumber);
const Promise = require("bluebird");
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

// Found here https://gist.github.com/xavierlepretre/afab5a6ca65e0c52eaf902b50b807401
var getEventsPromise = function (myFilter, count) {
  return new Promise(function (resolve, reject) {
    count = count ? count : 1;
    var results = [];
    myFilter.watch(function (error, result) {
      if (error) {
        reject(error);
      } else {
        count--;
        results.push(result);
      }
      if (count <= 0) {
        resolve(results);
        myFilter.stopWatching();
      }
    });
  });
};

// Found here https://gist.github.com/xavierlepretre/d5583222fde52ddfbc58b7cfa0d2d0a9
var expectedExceptionPromise = function (action, gasToUse) {
  return new Promise(function (resolve, reject) {
      try {
        resolve(action());
      } catch(e) {
        reject(e);
      }
    })
    .then(function (txn) {
      return web3.eth.getTransactionReceiptMined(txn);
    })
    .then(function (receipt) {
      // We are in Geth
      assert.equal(receipt.gasUsed, gasToUse, "should have used all the gas");
    })
    .catch(function (e) {
      if ((e + "").indexOf("invalid JUMP") > -1) {
        // We are in TestRPC
      } else {
        throw e;
      }
    });
};


contract('ShopFront', function(accounts) {
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

    it("should allow add of a product", () => {
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
                //blockNumber = web3.eth.blockNumber + 1;
                return instance.addProduct(1, 10, 1, {
                    from: accounts[0]
                });
            })
            .then(function(tx) {
              console.log(tx);
              //return Promise.all([
              //	    		getEventsPromise(instance.LogProductAdded(
              //	    			{},
              //	    			{ fromBlock: blockNumber, toBlock: "latest" })),
              //	    		web3.eth.getTransactionReceiptMined(tx)
              //    		]);

                //return web3.eth.getTransactionReceiptMined(tx);

            })
            //.then (function(receipt) {
            //  console.log(receipt);
            //});
    });
});
