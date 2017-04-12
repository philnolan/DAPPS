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
              return  web3.eth.getBalance(window.bobAddr);
            }).then(function(balance) {
              $("#bobsBalance").html(balance.toString(10));
              return  web3.eth.getBalance(window.carolAddr);
            }).then(function(balance) {
              $("#carolsBalance").html(balance.toString(10));
              return splitter.getAvailable.call(bobsId);
            }).then(function(balance) {
              $("#bobsAvailableBalance").html(balance.toString(10));
              return splitter.getAvailable.call(carolsId);
            }).then(function(balance) {
              $("#carolsAvailableBalance").html(balance.toString(10));
              return splitter.getTotal.call(bobsId);
            }).then(function(balance) {
              $("#bobsTotalBalance").html(balance.toString(10));
              return splitter.getTotal.call(carolsId);
            }).then(function(balance) {
              $("#carolsTotalBalance").html(balance.toString(10));
            });

}

window.addEventListener('load', function() {

    $("#status").html("Loading...");

    web3.eth.getAccountsPromise()
        .then(accounts => {
            window.account = accounts[0];
            window.bobAddr = accounts[1];
            window.carolAddr = accounts[2];
            $("#bobsAddress").html(accounts[bobsId]);
            $("#carolsAddress").html(accounts[carolsId]);
            return Splitter.deployed(window.bobAddr, window.carolAddr, { from: window.account});
          }).then(function(instance) {
            console.log(instance);
            $("#address").html(instance.address);
            return refreshBalances(instance);
          })
          .catch(e => {
              $("#status").html(e.toString());
              console.error(e);
          });

    $("#send").click(sendCoin);
    $("#bobClaim").click(claimCoin);
    //$("#carolClaim").click(claimCoin(2,window.carolAddr));

});

require("file-loader?name=../index.html!../index.html");



const sendCoin = function() {
    let deployed;
    return Splitter.deployed(window.bobAddr, window.carolAddr, { from: window.account})
        .then(_deployed => {
          console.log(deployed);
            deployed = _deployed;
            // .sendTransaction so that we get the txHash immediately.
            return _deployed.sendCoin.sendTransaction(
                { from: window.account, value: $("input[name='amount']").val() });
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
                console.log(deployed.SplitCoinTrans().formatter(receipt.logs[0]).args);
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
    return Splitter.deployed(window.bobAddr, window.carolAddr, { from: window.account})
        .then(_deployed => {
            deployed = _deployed;
            console.log(window.bobAddr);
            // .sendTransaction so that we get the txHash immediately.
            return deployed.claimAvailable.sendTransaction(1, { from: window.bobAddr });
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
                console.log(deployed.Claimed().formatter(receipt.logs[0]).args);
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
