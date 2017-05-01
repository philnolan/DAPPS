pragma solidity ^ 0.4 .4;

contract Splitter0 {

    address owner;
    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }


    struct Beneficiary {
        address addr;
        uint available; //what is up for grabs
        uint totalClaimed; //total amount user has grabbed the dosh
    }

    Beneficiary bob;
    Beneficiary carol;

    uint public totalSent;
    uint public totalClaimed;

    event CoinSentAndSplit(uint value, uint split, uint remainder);
    event CoinClaimed(address id, uint value);

    function Splitter0(address bobAddr, address carolAddr) {
        owner = msg.sender;
        bob = Beneficiary({
            addr: bobAddr,
            available: 0,
            totalClaimed: 0
        });
        carol = Beneficiary({
            addr: carolAddr,
            available: 0,
            totalClaimed: 0
        });
    }


    //returns array of beneficiary detail - called by them and passing in owner
    function getBeneficiaryDetail(address beneficiaryAddr) constant returns(uint available, uint totalClaimed) {
        if (beneficiaryAddr == bob.addr) {
            return (bob.available, bob.totalClaimed);
        } else {
            if (beneficiaryAddr == carol.addr) {
                return (carol.available, carol.totalClaimed);
            } else throw;
        }
    }

    function sendCoin() onlyOwner payable returns(bool successful) {

        //if they have sent the lowest amount possible which can not be shared
        if (msg.value < 1 wei) throw;

        //calculate share and remainder
        var coin = msg.value;
        var countBeneficiaries = 2;
        var perBenificiary = coin / 2;
        var totalToShare = perBenificiary * countBeneficiaries;
        var remainder = coin - totalToShare;

        //share between beneficiaries
        bob.available += perBenificiary;
        carol.available += perBenificiary;

        //increment covenant total spend
        totalSent += totalToShare;

        //give back remainder
        if (remainder > 0) {
            if (!msg.sender.send(remainder)) throw;
        }

        //write event
        CoinSentAndSplit(coin, perBenificiary, remainder);

        return true;
    }

    function claimAvailable() returns(bool successful) {

        uint available = 0;

        if (msg.sender == bob.addr) {
            available = bob.available;
        } else {
            if (msg.sender == carol.addr) {
                available = carol.available;
            } else throw;
        }

        //throw if nothing available or there is more than in contracts pot
        if (available == 0) throw;
        if (this.balance < available) throw;

        //set party detail
        if (msg.sender == bob.addr) {
            bob.available = 0;
            bob.totalClaimed += available;
        } else {
            if (msg.sender == carol.addr) {
                carol.available = 0;
                carol.totalClaimed += available;
            } else throw;
        }

        totalClaimed += available;

        //fingers crossed
        if (!msg.sender.send(available)) throw;

        //write log
        CoinClaimed(msg.sender, available);

        return true;
    }
}
