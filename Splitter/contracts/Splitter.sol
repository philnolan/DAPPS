
pragma solidity ^0.4.4;
import "./Owned.sol";
contract Splitter is Owned {

	struct Beneficiary {
	  uint available;		//what is up for grabs
		uint totalClaimed;	//total amount user has grabbed the dosh
		bool isActive;  	//to identify if we have set this address via correct route
	}

	struct Covenant {
	  mapping (address => Beneficiary) beneficiaries;
	  mapping (uint => address) beneficiariesMap;  //mapper to address array to help send coin
	  uint countBeneficiaries;
		uint totalSent;
	}

	//lets implement a max for the time being to ease complexity
	uint constant maxBeneficiaries = 2;

	mapping (address => Covenant) covenants;

	event ConventCreated(address addr);
	event BeneficiaryAdded(address owner, address beneficiary);
	event CoinSentAndSplit(uint value, uint split,  uint remainder);
	event CoinClaimed(address id, address id2, uint value);

	function Splitter() {}

	function createCovenant () {

		//todo:  ensure same address cannot create a second
	  covenants[msg.sender] = Covenant({
	        totalSent: 0, countBeneficiaries:0
	  });

		ConventCreated(msg.sender);
	}

	function addBeneficiary (address beneficiaryAddr) onlyowner {

		//have we exceeded max
		if (maxBeneficiaries == covenants[msg.sender].countBeneficiaries) throw;

		//test for beneficiary already been added
		if (covenants[msg.sender].beneficiaries[beneficiaryAddr].isActive) throw;

	  var counter = covenants[msg.sender].countBeneficiaries ++;
	  covenants[msg.sender].beneficiaries[beneficiaryAddr] = Beneficiary({available:0, totalClaimed:0, isActive:true});
		covenants[msg.sender].beneficiariesMap[counter] = beneficiaryAddr;

		BeneficiaryAdded(msg.sender, beneficiaryAddr);
	}


	//returns array of beneficiary detail - called by them and passing in owner
	function getBeneficiaryDetail(address covenantOwner) constant returns(uint available, uint totalClaimed) {
		//test to ensure sender is a beneficiary, throw if not
		if (!covenants[covenantOwner].beneficiaries[msg.sender].isActive) throw;

		return  (covenants[covenantOwner].beneficiaries[msg.sender].available,
					covenants[covenantOwner].beneficiaries[msg.sender].totalClaimed);

	}

	function sendCoin() onlyowner payable returns(bool successful)   {

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
		for(uint i=0; i < counter; i++) {
			var idxAddr = covenants[msg.sender].beneficiariesMap[i];
        	covenants[msg.sender].beneficiaries[idxAddr].available += perBenificiary;
        }

		//increment covenant total spend
		covenants[msg.sender].totalSent += totalToShare;

		//give back remainder
		if (remainder > 0)
			{
				if (!msg.sender.send(remainder)) throw;
			}

		//write event
		CoinSentAndSplit(coin, perBenificiary, remainder);

		return true;
	}

	function claimAvailable(address covenantOwner) returns(bool successful)  {

	  //test to ensure sender is a beneficiary, throw if not
		if (!covenants[covenantOwner].beneficiaries[msg.sender].isActive) throw;

		var available = covenants[covenantOwner].beneficiaries[msg.sender].available;

		//throw if nothing available or there is more than in contracts pot
		if (available == 0) throw;
		if (this.balance < available) throw;

		//set party detail
		covenants[covenantOwner].beneficiaries[msg.sender].available = 0;
		covenants[covenantOwner].beneficiaries[msg.sender].totalClaimed += available;

		//fingers crossed
		if (!msg.sender.send(available)) throw;

		//write log
		CoinClaimed(msg.sender, covenantOwner, available);

		return true;
	}

	function kill() {
		//if originator then destruct and fund
    if (msg.sender == owner) {
        selfdestruct(owner);
  	}
	}
}
