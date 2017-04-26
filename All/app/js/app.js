const Web3 = require("web3");
const Promise = require("bluebird");
const truffleContract = require("truffle-contract");
const $ = require("jquery");
// Not to forget our built contract
const splitterJson = require("../../build/contracts/Splitter.json");

const bobsId = 1;
const carolsId = 2;

// Supports Mist, and other wallets that provide 'web3'.
if (typeof web3 !== 'undefined') {
    // Use the Mist/wallet/Metamask provider.
    window.web3 = new Web3(web3.currentProvider);
} else {
    // Your preferred fallback.
    window.web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
}

Promise.promisifyAll(web3.eth, { suffix: "Promise" });

const Splitter = truffleContract(splitterJson);
Splitter.setProvider(web3.currentProvider);


const refreshBalances = function(splitter) {

  return  web3.eth.getBalancePromise(splitter.address)
            .then(function(balance) {
              $("#balance").html(balance.toString(10));
              return  web3.eth.getBalancePromise(window.account0);
            }).then(function(balance) {
              $("#acc0Balance").html(balance.toString(10));
              return  web3.eth.getBalancePromise(window.account1);
            }).then(function(balance) {
              $("#acc1Balance").html(balance.toString(10));
              return  web3.eth.getBalancePromise(window.account2);
            }).then(function(balance) {
              $("#acc2Balance").html(balance.toString(10));
              return splitter.getBeneficiaryDetail.call(window.account0, { from: window.account1});
            }).then(function(balance) {
              $("#ben1AvailableBalance").html(balance[0].toString(10));
              $("#ben1TotalBalance").html(balance[1].toString(10));
              return splitter.getBeneficiaryDetail.call(window.account0, { from: window.account2});
            }).then(function(balance) {
              $("#ben2AvailableBalance").html(balance[0].toString(10));
              $("#ben2TotalBalance").html(balance[1].toString(10));
                //return splitter.getAvailable.call(carolsId);
            //}).then(function(balance) {
            //  $("#carolsAvailableBalance").html(balance.toString(10));
            //  return splitter.getTotal.call(bobsId);
          //}).then(function(balance) {
          //    $("#bobsTotalBalance").html(balance.toString(10));
          //    return splitter.getTotal.call(carolsId);
          //  }).then(function(balance) {
          //    $("#carolsTotalBalance").html(balance.toString(10));
            });

}

window.addEventListener('load', function() {

    $("#status").html("Loading...");

    web3.eth.getAccountsPromise()
        .then(accounts => {

            window.account0 = accounts[0];
            window.account1 = accounts[1];
            window.account2 = accounts[2];

            $("#accounts").html(accounts[0] + " : " + accounts[1] + " : " + accounts[2]);
            $("#owner").val(accounts[0]);
            $("#beneficiary").val(accounts[1]);
            $("#claimAddr").val(accounts[1]);

            $("#acc0Address").html(accounts[0]);
            $("#acc1Address").html(accounts[1]);
            $("#acc2Address").html(accounts[2]);
            return Splitter.deployed();
          }).then(function(instance) {
            //console.log(instance);
            $("#address").html(instance.address);
            return refreshBalances(instance);
          })
          .catch(e => {
              $("#status").html(e.toString());
              console.error(e);
          });

    $("#create").click(createCovenant);
    $("#add").click(addBeneficiary);
    $("#send").click(sendCoin);
    $("#claim").click(claimCoin);
    //$("#carolClaim").click(claimCoin(2,window.carolAddr));

});

require("file-loader?name=../index.html!../index.html");


const createCovenant = function() {
    let deployed;

    return Splitter.deployed()
        .then(_deployed => {
            deployed = _deployed;
            // .sendTransaction so that we get the txHash immediately.
            return deployed.createCovenant.sendTransaction({ from: $("input[id='owner']").val() });
        })
        .then(txHash => {
            $("#status").html("Transaction on the way " + txHash);
            // Now we wait for the tx to be mined.
            const tryAgain = () => web3.eth.getTransactionReceiptPromise(txHash)
                .then(receipt => receipt !== null ?
                    receipt :
                    // Let's hope we don't hit the max call stack depth
                    Promise.delay(500).then(tryAgain));
            return tryAgain();
        })
        .then(receipt => {
            if (receipt.logs.length == 0) {
                console.error("Empty logs");
                console.error(receipt);
                $("#status").html("There was an error in the tx execution");
            } else {
                // Format the event nicely.
                console.log(deployed.CovenantCreated().formatter(receipt.logs[0]).args);
                $("#status").html("Transfer executed");
            }
            // Make sure we update the UI.
            return refreshBalances(deployed);
          })
        .catch(e => {
            $("#status").html(e.toString());
            console.error(e);
        });
};


const addBeneficiary = function() {
    let deployed;


    return Splitter.deployed()
        .then(_deployed => {
            deployed = _deployed;
            // .sendTransaction so that we get the txHash immediately.
            return deployed.addBeneficiary.sendTransaction($("input[id='beneficiary']").val()
                                                            ,{ from: $("input[id='owner']").val(),
                                                                gas:120000 });
        })
        .then(txHash => {
            $("#status").html("Transaction on the way " + txHash);
            // Now we wait for the tx to be mined.
            const tryAgain = () => web3.eth.getTransactionReceiptPromise(txHash)
                .then(receipt => receipt !== null ?
                    receipt :
                    // Let's hope we don't hit the max call stack depth
                    Promise.delay(500).then(tryAgain));
            return tryAgain();
        })
        .then(receipt => {
            if (receipt.logs.length == 0) {
                console.error("Empty logs");
                console.error(receipt);
                $("#status").html("There was an error in the tx execution");
            } else {
                // Format the event nicely.
                console.log(deployed.BeneficiaryAdded().formatter(receipt.logs[0]).args);
                $("#status").html("Transfer executed");
            }
            // Make sure we update the UI.
            return refreshBalances(deployed);
          })
        .catch(e => {
            $("#status").html(e.toString());
            console.error(e);
        });
};

const sendCoin = function() {
    let deployed;
    console.log($("input[id='owner']").val());
    console.log($("amount").val());
    return Splitter.deployed()
        .then(_deployed => {
          console.log(deployed);
            deployed = _deployed;
            // .sendTransaction so that we get the txHash immediately.
            return _deployed.sendCoin.sendTransaction(
                { from: $("input[id='owner']").val(), value: $("input[id='amount']").val() });
        })
        .then(txHash => {
            $("#status").html("Transaction on the way " + txHash);
            // Now we wait for the tx to be mined.
            const tryAgain = () => web3.eth.getTransactionReceiptPromise(txHash)
                .then(receipt => receipt !== null ?
                    receipt :
                    // Let's hope we don't hit the max call stack depth
                    Promise.delay(500).then(tryAgain));
            return tryAgain();
        })
        .then(receipt => {
            if (receipt.logs.length == 0) {
                console.error("Empty logs");
                console.error(receipt);
                $("#status").html("There was an error in the tx execution");
            } else {
                // Format the event nicely.
                console.log(deployed.CoinSentAndSplit().formatter(receipt.logs[0]).args);
                $("#status").html("Transfer executed");
            }
            // Make sure we update the UI.
            return refreshBalances(deployed);
          })
        .catch(e => {
            $("#status").html(e.toString());
            console.error(e);
        });
};


const claimCoin = function() {
    let deployed;
    return Splitter.deployed()
        .then(_deployed => {
            deployed = _deployed;
            // .sendTransaction so that we get the txHash immediately.
            return deployed.claimAvailable.sendTransaction($("input[id='owner']").val(), { from: $("input[id='claimAddr']").val() });
        })
        .then(txHash => {
            $("#status").html("Transaction on the way " + txHash);
            // Now we wait for the tx to be mined.
            const tryAgain = () => web3.eth.getTransactionReceiptPromise(txHash)
                .then(receipt => receipt !== null ?
                    receipt :
                    // Let's hope we don't hit the max call stack depth
                    Promise.delay(500).then(tryAgain));
            return tryAgain();
        })
        .then(receipt => {
            if (receipt.logs.length == 0) {
                console.error("Empty logs");
                console.error(receipt);
                $("#status").html("There was an error in the tx execution");
            } else {
                // Format the event nicely.
                console.log(deployed.CoinClaimed().formatter(receipt.logs[0]).args);
                $("#status").html("Transfer executed");
            }
            // Make sure we update the UI.
            return refreshBalances(deployed);
          })
        .catch(e => {
            $("#status").html(e.toString());
            console.error(e);
        });
};
