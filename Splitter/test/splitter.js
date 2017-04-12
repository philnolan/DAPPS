var Splitter = artifacts.require("./Splitter.sol");



contract('Splitter', function(accounts) {



	var expectedExceptionPromise = function (action, gasToUse) {
	  return new Promise(function (resolve, reject) {
	      try {
	        resolve(action());
	      } catch(e) {
	        reject(e);
	      }
	    })
	    .then(function (txn) {
	      // https://gist.github.com/xavierlepretre/88682e871f4ad07be4534ae560692ee6
	      return web3.eth.getTransactionReceiptMined(txn);
	    })
	    .then(function (receipt) {
	      // We are in Geth
	      assert.equal(receipt.gasUsed, gasToUse, "should have used all the gas");
	    })
	    .catch(function (e) {
	      if ((e + "").indexOf("invalid JUMP") || (e + "").indexOf("out of gas") > -1) {
	        // We are in TestRPC
	      } else if ((e + "").indexOf("please check your gas amount") > -1) {
	        // We are in Geth for a deployment
	      } else {
	        throw e;
	      }
	    });
	};

	var splitter

	beforeEach(function() {
        return Splitter.new(accounts[1], accounts[2], { from: accounts[0] }).then(function(i){
        	splitter = i
	        })
    	})

	var bobsId = 1;
	var carolsId = 2;

	it("should put 0 into each beneficiary balance upon creation", function() {
		// Get initial balances of first and second account.

    		var bobsBalance;
	    	var carolsBalance;

    		//return splitter.bobAddr().then(function(addr) { console.log("test"); console.log(addr) });

    		return splitter.getAvailable.call(bobsId)
			.then(function(balance) {
	      		bobsBalance = balance.toNumber();
      			return splitter.getAvailable.call(carolsId);})
		.then(function(balance) {
      			assert.equal(bobsBalance, 0, "should be zero balance for bob");
      			assert.equal(balance, 0, "should be zero balance for carol");});
    	});

 	it("should put split into each beneficiary balance upon send", function() {
	    // Get initial balances of first and second account.

 		var bobsBalance;
		var carolsBalance;
 		var val = web3.toWei(2, "ether");
 		var splitVal = val / 2;

		//return splitter.bobsDosh().then(function(addr) { console.log(addr.toNumber()) });

		return splitter.sendCoin.sendTransaction({ from: accounts[0], value: val })
			.then(function() {
			return splitter.getAvailable.call(bobsId);
 		}).then(function(balance) {
			bobsBalance = balance.toString(10);
		      	return splitter.getAvailable.call(carolsId);
	    	}).then(function(balance) {
			carolsBalance = balance.toString(10);
			assert.equal(bobsBalance, splitVal, "should be balance  of 1 for bob");
			assert.equal(carolsBalance, splitVal, "should be balance of 1 for carol");
		});
	});

	it("should throw when zero passed in send", function() {

		splitter.sendCoin.sendTransaction({ from: accounts[0] })

		assert.isTrue(false);
	});

	it("should throw when 1 wei passed in send", function() {

		assert.isTrue(false);
	});


});
