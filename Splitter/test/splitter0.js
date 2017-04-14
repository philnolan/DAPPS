var Splitter = artifacts.require("./Splitter0.sol");

contract('Splitter', function(accounts) {
    var splitter
    var alice = accounts[0];
    var bob = accounts[1];
    var carol = accounts[2];


    beforeEach(function() {
        return Splitter.new(bob, carol, {
            from: alice
        }).then(function(i) {
            splitter = i
        })
    })


    it("should accept coin ", function() {
        var val = web3.toWei(1, "ether");
        var splitVal = val / 2;
        return splitter.sendCoin.sendTransaction({
                from: alice,
                value: val
            })
            .then(function() {
                return splitter.totalSent.call({
                    from: alice
                });
            }).then(function(result) {
                assert.equal(result, val, "should be 1 ETH");
                return splitter.totalClaimed.call({
                    from: alice
                });
            }).then(function(result) {
                assert.equal(result, 0, "should be zero total claimed");
                return splitter.getBeneficiaryDetail.call(bob, {
                    from: alice
                });
            }).then(function(result) {
                assert.equal(result[0], splitVal, "should be .5 ETH for beneficiary available balance");
                assert.equal(result[1], 0, "should be zero for beneficiary total claimed");
                return splitter.getBeneficiaryDetail.call(carol, {
                    from: alice
                });
            }).then(function(result) {
                assert.equal(result[0], splitVal, "should be .5 ETH for beneficiary available balance");
                assert.equal(result[1], 0, "should be zero for beneficiary total claimed");
            });
    });

    it("should allow legit claim to be made", function() {
        var val = web3.toWei(1, "ether");
        var splitVal = val / 2;

        return splitter.sendCoin.sendTransaction({
                from: alice,
                value: val
            })
            .then(function() {
                return splitter.claimAvailable.sendTransaction({
                    from: bob
                })
            }).then(function() {
                return splitter.totalClaimed.call({
                    from: alice
                });
            }).then(function(result) {
                assert.equal(result, splitVal, "should be .5 ETH");
                return splitter.getBeneficiaryDetail.call(bob, {
                    from: alice
                });
            }).then(function(result) {
                assert.equal(result[0], 0, "should be zero for beneficiary available balance");
                assert.equal(result[1], splitVal, "should be .5 ETH for beneficiary total claimed");
                return splitter.claimAvailable.sendTransaction({
                    from: carol
                })
            }).then(function() {
                return splitter.totalClaimed.call({
                    from: alice
                });
            }).then(function(result) {
                assert.equal(result, val, "should be 1 ETH");
                return splitter.getBeneficiaryDetail.call(carol, {
                    from: alice
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
