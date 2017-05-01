pragma solidity ^ 0.4.4;

contract Splitter {

    struct Beneficiary {
        uint available; //what is up for grabs
        uint totalClaimed; //total amount user has grabbed the dosh
        bool isActive; //to identify if we have set this address via correct route
    }

    struct Covenant {
        mapping(address => Beneficiary) beneficiaries;
        mapping(uint => address) beneficiariesMap; //mapper to address array to help send coin
        uint countBeneficiaries;
        uint totalSent;
        uint totalClaimed;
        bool isActive; //to identify if the active
    }

    //lets implement a max for the time being to ease complexity
    uint constant maxBeneficiaries = 2;

    mapping(address => Covenant) covenants;

    event LogCovenantCreated(address addr);
    event LogBeneficiaryAdded(address owner, address beneficiary);
    event LogCoinSentAndSplit(uint value, uint split, uint remainder);
    event LogCoinClaimed(address id, address id2, uint value);
    event LogCovenantClosed(address id, uint value);

    function Splitter() {}

    function createCovenant() {

        //test for beneficiary already been added
        if (covenants[msg.sender].isActive) throw;

        covenants[msg.sender] = Covenant({
            totalSent: 0,
            totalClaimed: 0,
            countBeneficiaries: 0,
            isActive: true
        });

        LogCovenantCreated(msg.sender);
    }

    function getCovenantDetail() constant returns(uint countBeneficiaries,
        uint totalSent,
        uint totalClaimed,
        bool isActive) {


        return (covenants[msg.sender].countBeneficiaries,
            covenants[msg.sender].totalSent,
            covenants[msg.sender].totalClaimed,
            covenants[msg.sender].isActive);
    }


    function addBeneficiary(address beneficiaryAddr) returns(bool successful) {
        //throw if not active

        Covenant covenant = covenants[msg.sender];
        if (!covenant.isActive) throw;

        //have we exceeded max
        if (maxBeneficiaries == covenant.countBeneficiaries) throw;

        //test for beneficiary already been added

        Beneficiary beneficiary = covenant.beneficiaries[beneficiaryAddr];
        if (beneficiary.isActive) throw;
        uint counter = covenant.countBeneficiaries++;
        beneficiary.isActive = true;
        covenant.beneficiariesMap[counter] = beneficiaryAddr;

        LogBeneficiaryAdded(msg.sender, beneficiaryAddr);
    }


    //returns array of beneficiary detail - called by them and passing in owner
    function getBeneficiaryDetail(address covenantOwner) constant returns(uint available, uint totalClaimed) {
        //test to ensure sender is a beneficiary, throw if not
        if (!covenants[covenantOwner].beneficiaries[msg.sender].isActive) throw;

        return (covenants[covenantOwner].beneficiaries[msg.sender].available,
            covenants[covenantOwner].beneficiaries[msg.sender].totalClaimed);

    }

    function sendCoin() payable returns(bool successful) {

        //thow if not active
        if (!covenants[msg.sender].isActive) throw;

        //if they have sent the lowest amount possible which can not be shared
        if (msg.value < 1 wei) throw;

        //we have parties to share to?
        if (covenants[msg.sender].countBeneficiaries == 0) throw;

        //calculate share and remainder
        var coin = msg.value;
        var countBeneficiaries = covenants[msg.sender].countBeneficiaries;
        var perBenificiary = coin / countBeneficiaries;
        var totalToShare = perBenificiary * countBeneficiaries;
        var remainder = coin - totalToShare;

        //share between beneficiaries
        var counter = covenants[msg.sender].countBeneficiaries;
        for (uint i = 0; i < counter; i++) {
            var idxAddr = covenants[msg.sender].beneficiariesMap[i];
            covenants[msg.sender].beneficiaries[idxAddr].available += perBenificiary;
        }

        //increment covenant total spend
        covenants[msg.sender].totalSent += totalToShare;

        //give back remainder
        if (remainder > 0) {
            if (!msg.sender.send(remainder)) throw;
        }

        //write event
        LogCoinSentAndSplit(coin, perBenificiary, remainder);

        return true;
    }

    function claimAvailable(address covenantOwner) returns(bool successful) {

        //test to ensure sender is a beneficiary, throw if not
        if (!covenants[covenantOwner].beneficiaries[msg.sender].isActive) throw;

        var available = covenants[covenantOwner].beneficiaries[msg.sender].available;

        //throw if nothing available or there is more than in contracts pot
        if (available == 0) throw;
        if (this.balance < available) throw;

        //set party detail
        covenants[covenantOwner].beneficiaries[msg.sender].available = 0;
        covenants[covenantOwner].beneficiaries[msg.sender].totalClaimed += available;
        covenants[covenantOwner].totalClaimed += available;

        //fingers crossed
        if (!msg.sender.send(available)) throw;

        //write log
        LogCoinClaimed(msg.sender, covenantOwner, available);

        return true;
    }

    function closeCovenant() returns(bool successful) {

        Covenant covenant = covenants[msg.sender];
        if (!covenant.isActive) throw;

        var sent = covenant.totalSent;
        var claimed = covenant.totalClaimed;
        var total = sent - claimed;

        if (this.balance < total) throw;

        covenant.totalSent = 0;
        covenant.totalClaimed = 0;
        covenant.isActive = false;

        //fingers crossed
        if (!msg.sender.send(total)) throw;

        //write log
        LogCovenantClosed(msg.sender, total);

        return true;
    }
}
