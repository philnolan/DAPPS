var Splitter = artifacts.require("./Splitter.sol");
var Splitter0 = artifacts.require("./Splitter0.sol");
//const Web3 = require("web3");
//const Promise = require("bluebird");

module.exports = function(deployer) {

  //var web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
  //Promise.promisifyAll(web3.eth, { suffix: "Promise" });

  //console.log(web3.isConnected());  //return false
  //web3.eth.getAccountsPromise()
  //    .then(accounts => {
  //         console.log(accounts[0]);
  //         //alice = accounts[0];
  //         var bob = accounts[1];
  //         var carol = accounts[2];
  //       });

    //deployer.deploy(Splitter, bob, carol)
    deployer.deploy(Splitter)
    deployer.deploy(Splitter0)
};
