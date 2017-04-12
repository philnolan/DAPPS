var ConvertLib = artifacts.require("./ConvertLib.sol");
var MetaCoin = artifacts.require("./MetaCoin.sol");
var Splitter = artifacts.require("./Splitter.sol");
const Web3 = require("web3");
const Promise = require("bluebird");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(MetaCoin);


  var web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
  Promise.promisifyAll(web3.eth, { suffix: "Promise" });

  console.log(web3.isConnected());  //return false
  web3.eth.getAccountsPromise()
      .then(accounts => {
           console.log(accounts[0]);
           //alice = accounts[0];
           var bob = accounts[1];
           var carol = accounts[2];
           deployer.deploy(Splitter, bob, carol)
         });
//console.log(web3.eth.accounts[0]);
  //deployer.then(() => web3.ethß.getAccountsPromise()
  //    .then(accounts => {
  //         alice = accounts[0];
  //         bob = accounts[1];
  //         carol = accounts[2];
           //deployer.deploy(Splitter, bob, carol);
          //return Splitter.deployed(window.bobAddr, window.carolAddr, { from: window.account});
  //      }).

  //deployer.then(() => web3.eth.getAccountsPromise()).then(accounts =>



};
