const Splitter = artifacts.require("./Splitter.sol");
const Promise = require("bluebird");


web3.eth.getTransactionReceiptMined = function (txnHash, interval) {
    var transactionReceiptAsync;
    interval |= 500;
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




contract('Splitter', function(accounts) {
    var splitter
    var events;
    let owner, acc1, acc2;

    before("should prepare", function() {
            owner = accounts[0];
            acc1 = accounts[1];
            acc2 = accounts[2];

            Promise.promisifyAll(web3.eth, { suffix: "Promise" });
        });


    it("should return zero'd covenant upon creation", function() {

        return Splitter.deployed().then(function(instance) {
            splitter = instance;

            return splitter.createCovenant.sendTransaction({
                from: owner
            });
        }).then(function(result) {
            return splitter.getCovenantDetail.call({
                from: owner
            });
        }).then(function(result) {
            assert.equal(result[0], 0, "should be zero for beneficiary count");
            assert.equal(result[1], 0, "should be zero total sent");
            assert.equal(result[2], 0, "should be zero total claimed");
        });
    });

    it("should not allow owner to create 2 covenants", function() {
        return Splitter.deployed().then(function(instance) {
            splitter = instance;
            return splitter.createCovenant.sendTransaction({
                from: owner
            });
        }).then(function() {
            return false; //should not have got here
        }).catch(function(e) {
            return true;
        });
    });

    it("should put 0 into beneficiary balance upon adding each ", function() {
        return Splitter.deployed().then(function(instance) {
            splitter = instance;
        }).then(function(result) {
            return splitter.addBeneficiary.sendTransaction(acc1, {
                from: owner
            });
        }).then(function() {
            return splitter.getBeneficiaryDetail.call(owner, {
                from: acc1
            });
        }).then(function(result) {
            assert.equal(result[0], 0, "should be zero for beneficiary available balance");
            assert.equal(result[1], 0, "should be zero for beneficiary total claimed");
            return splitter.addBeneficiary.sendTransaction(acc2, {
                from: owner
            })
        }).then(function(result) {
            return splitter.getBeneficiaryDetail.call(owner, {
                from: acc2
            });
        }).then(function(result) {
            assert.equal(result[0], 0, "should be zero for beneficiary available balance");
            assert.equal(result[1], 0, "should be zero for beneficiary total claimed");
            return splitter.getCovenantDetail.call({
                from: owner
            });
        }).then(function(result) {
            assert.equal(result[0], 2, "should be two for beneficiary count");
            assert.equal(result[1], 0, "should be zero total sent");
            assert.equal(result[2], 0, "should be zero total claimed");
        });
    });

    it("should accept coin, update ccontract balance and convenant/beneficiary detail", function() {
        var val = web3.toWei(1, "ether");
        var splitVal = val / 2;
        return Splitter.deployed().then(function(instance) {
            splitter = instance;
            return splitter.sendCoin.sendTransaction({
                from: owner,
                value: val
            })
        }).then(reult => splitter.getCovenantDetail.call({
                from: owner
            })
        ).then(function(result) {
            assert.equal(result[0], 2, "should be 2 for benefciary count");
            assert.equal(result[1], val, "should be 1 ETH total sent");
            assert.equal(result[2], 0, "should still be zero total claimed");
            return splitter.getBeneficiaryDetail.call(owner, {
                from: acc1
            });
        }).then(function(result) {
            assert.equal(result[0], splitVal, "should be .5 ETH for beneficiary available balance");
            assert.equal(result[1], 0, "should be zero for beneficiary total claimed");
            return splitter.getBeneficiaryDetail.call(owner, {
                from: acc2
            });
        }).then(function(result) {
            assert.equal(result[0], splitVal, "should be .5 ETH for beneficiary available balance");
            assert.equal(result[1], 0, "should be zero for beneficiary total claimed");
        });
    });

    it("should allow legit claim to be made", function() {
        var val = web3.toWei(1, "ether");
        var splitVal = val / 2;

        return Splitter.deployed().then(function(instance) {
            splitter = instance;
            return splitter.claimAvailable.sendTransaction(owner, {
                from: acc1
            })
        }).then(reult => splitter.getCovenantDetail.call({
                from: owner
            })
        ).then(function(result) {
            assert.equal(result[0], 2, "should be 2 for benefciary count");
            assert.equal(result[1], val, "should be 1 ETH total sent");
            assert.equal(result[2], splitVal, "should .5 ETH total claimed");
            return splitter.getBeneficiaryDetail.call(owner, {
                from: acc1
            });
        }).then(function(result) {
            assert.equal(result[0], 0, "should be zero for beneficiary available balance");
            assert.equal(result[1], splitVal, "should be .5 ETH for beneficiary total claimed");
            return splitter.claimAvailable.sendTransaction(owner, {
                from: acc2
            })
        }).then(result => splitter.getCovenantDetail.call({
                from: owner
            })
        ).then(function(result) {
            assert.equal(result[0], 2, "should be 2 for benefciary count");
            assert.equal(result[1], val, "should be 1 ETH total sent");
            assert.equal(result[2], val, "should still be zero total claimed");
            return splitter.getBeneficiaryDetail.call(owner, {
                from: acc2
            });
        }).then(function(result) {
            assert.equal(result[0], 0, "should be zero for beneficiary available balance");
            assert.equal(result[1], splitVal, "should be .5 ETH for beneficiary total claimed");
        });
    });
});

//it("should split odd values correctly and return remainder to owner", function() {

//it("should not allow coin to be claimed with incorrect address", function() {
//it("should allow coin to be claimed by valid beneficiaries", function() {
//it("should allow owner to close convenant", function() {




//	it("should put split into each beneficiary balance upon send", function() {
// Get initial balances of first and second account.

//		var bobsBalance;
//		var carolsBalance;
//		var val = web3.toWei(2, "ether");
//		var splitVal = val / 2;
//
//		//return splitter.bobsDosh().then(function(addr) { console.log(addr.toNumber()) });
//
//		return splitter.sendCoin.sendTransaction({ from: accounts[0], value: val })
//			.then(function() {
//			return splitter.getAvailable.call(bobsId);
//		}).then(function(balance) {
//			bobsBalance = balance.toString(10);
//		      	return splitter.getAvailable.call(carolsId);
//	    	}).then(function(balance) {
//			carolsBalance = balance.toString(10);
//			assert.equal(bobsBalance, splitVal, "should be balance  of 1 for bob");
//			assert.equal(carolsBalance, splitVal, "should be balance of 1 for carol");
//		});
//	});

//it("should throw when zero passed in send", function() {
//it("should throw when 1 wei passed in send", function() {
