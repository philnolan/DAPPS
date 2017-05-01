var Splitter = artifacts.require("./Splitter.sol");
var ShopKeeper = artifacts.require("./ShopKeeper.sol")
var ShopFront = artifacts.require("./ShopFront/ShopFront.sol")
var ConvertLib = artifacts.require("./ConvertLib.sol")
var MetaCoin = artifacts.require("./MetaCoin.sol")

module.exports = function(deployer) {

    deployer.deploy(ConvertLib);
    deployer.link(ConvertLib, MetaCoin);
    deployer.deploy(MetaCoin);

    deployer.deploy(Splitter);
    deployer.deploy(ShopKeeper);
    deployer.deploy(ShopFront);

};
