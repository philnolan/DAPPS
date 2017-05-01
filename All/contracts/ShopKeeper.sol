pragma solidity ^ 0.4.0;

//shopKeeper is master merchant
//products

contract ShopKeeper {

    //uint constant shopOwnerMerchantCode = 0;
    uint public merchantCount;
    address shopOwner;

    struct Product {
        string description;
        uint price;
        uint stock;
        uint idx;
    }

    enum MerchantStatus {Inexistent, AwaitingApproval, Rejected, Authorised}

    modifier onlyAuthorisedMerchant() {
        if (merchants[msg.sender].Status == MerchantStatus.Authorised) throw;
        _;
    }

    modifier onlyShopOwner() {
        if (msg.sender != shopOwner) throw;
        _;
    }


    //modifier atStatus(MerchantStatus status, MerchantStatus _hasToBeStatus) {
    //    if (status != hasToBeStatus) throw;
    //    _;
    //}

    struct Merchant {
        //address Address;
        string Name;
        MerchantStatus Status;
        uint ProductCount;
        uint Value;
        uint idx;
        bool isActive;
        mapping(uint => Product) products;
        uint[] productsIndex;
    }
    mapping(address => Merchant) merchants;
    //uint[] merchantsIndex;



    uint public shopGrossValue;

    event MerchantAdded(address merchantAddress, string name);
    event MerchantAuthorised(address merchantAddress);
    event MerchantRejected(address merchantAddress);


    event ProductAdded(address indexed merchantAddress, uint indexed productCode, uint idx, string description, uint price, uint stock);
    event ProductUpdated(address indexed merchantAddress, uint indexed productCode, uint idx, string description, uint price, uint stock);
    event ProductDeleted(address indexed merchantAddress, uint indexed productCode, uint idx);
    event ProductBought(address indexed merchantAddress, uint indexed productCode, address indexed buyer, uint quantity);

    function ShopKeeper() {
        shopOwner = msg.sender;
        merchants[shopOwner].Name = "shopOwner";
        merchants[shopOwner].Status = MerchantStatus.Authorised;
        merchants[shopOwner].isActive == true;
        //merchants[shopOwnerMerchantCode].idx = merchantCount;
        merchantCount++;
    }

    //////Start:  Merchant functions//////
    function getProductAtIndexForMerchant(uint idx)
    public
    constant
    returns(uint productCode) {
        return merchants[msg.sender].productsIndex[idx];
    }

    function addMerchant(string name )
    public
    payable
    {
        //test to make sure address is not already in use
        //and the code isn't used by keeper
        if (merchants[msg.sender].isActive == true) throw;
        if (msg.sender == shopOwner) throw;

        merchants[msg.sender].Name = name;
        merchants[msg.sender].Status = MerchantStatus.AwaitingApproval;
        //merchants[msg.sender].idx = merchantCount;
        merchants[msg.sender].isActive = true;

        //pay to be included?
        merchants[msg.sender].Value = msg.value;

        merchantCount++;

        MerchantAdded(msg.sender, name);
    }

    function changeMerchantStatus(address merchantAddress, MerchantStatus status)
    private
    returns (bool success)
    {
        if (merchants[merchantAddress].isActive == false) return false;
        if (merchantAddress == shopOwner) return false;

        if ( merchants[merchantAddress].Status == status)  return false;

        merchants[merchantAddress].Status = status;
        return true;
    }


    function authoriseMerchant(address merchantAddress)
    public
    onlyShopOwner
    returns (bool success)
    {
        if (changeMerchantStatus(msg.sender, MerchantStatus.Authorised)) {
            MerchantAuthorised(merchantAddress);
            return true;
        }
        return false;
    }

    function rejectMerchant(address merchantAddress)
    public
    onlyShopOwner
    returns (bool success) {

        if (changeMerchantStatus(msg.sender, MerchantStatus.Rejected)) {
            MerchantRejected(merchantAddress);
            return true;
        }
        return false;
    }


    function getProductCountForMerchant()
    public
    constant
    returns(uint count) {
        return merchants[msg.sender].productsIndex.length;
    }

    function makePayment()
    onlyShopOwner
    payable
    {}

    //TODO:  Merchant withdrawls - should shop keeper take a cut
    function makeWithdrawl(uint amount) onlyShopOwner {
        if (this.balance < amount) throw;

        if (!msg.sender.send(amount)) throw;
    }


    function killMe() onlyShopOwner returns(bool) {
        suicide(shopOwner);
        return true;
    }
    //////End:  Merchant functions//////

    //////Start:  Product functions//////

    //
    function isValidProduct(uint productCode, address merchantAddress)
    internal
    constant
    returns(bool isValid) {
        if (merchants[merchantAddress].productsIndex.length == 0) return false;
        uint idx = merchants[merchantAddress].products[productCode].idx;
        return (merchants[merchantAddress].productsIndex[idx] == productCode);
    }


    function addProduct(uint productCode, string description, uint price, uint stock)
    onlyAuthorisedMerchant()
    returns(bool success) {
        if (isValidProduct(productCode, msg.sender)) return false;

        merchants[msg.sender].products[productCode].description = description;
        merchants[msg.sender].products[productCode].price = price;
        merchants[msg.sender].products[productCode].stock = stock;
        merchants[msg.sender].products[productCode].idx = merchants[msg.sender].productsIndex.push(productCode) - 1;
        shopGrossValue += price * stock;
        merchants[msg.sender].ProductCount++;
        ProductAdded(msg.sender,
            productCode,
            merchants[msg.sender].products[productCode].idx,
            description,
            price,
            stock);
        return true;
    }

    function deleteProduct(uint productCode)
    public
    onlyAuthorisedMerchant()
    returns(bool success) {
        if (!isValidProduct(productCode,msg.sender)) return false;

        uint idxProductToDelete = merchants[msg.sender].products[productCode].idx;
        uint productCodeToShift = merchants[msg.sender].productsIndex[merchants[msg.sender].productsIndex.length - 1];

        shopGrossValue -= merchants[msg.sender].products[productCode].price * merchants[msg.sender].products[productCode].stock;

        merchants[msg.sender].productsIndex[idxProductToDelete] = productCodeToShift;
        merchants[msg.sender].products[productCodeToShift].idx = idxProductToDelete;

        merchants[msg.sender].productsIndex.length--;
        ProductDeleted(msg.sender,
            productCode,
            idxProductToDelete);

        return true;
    }

    function getProduct(uint productCode)
    public
    constant
    returns(string description, uint price, uint stock, uint idx) {
        if (!isValidProduct(productCode, msg.sender)) throw;
        return (
            merchants[msg.sender].products[productCode].description,
            merchants[msg.sender].products[productCode].price,
            merchants[msg.sender].products[productCode].stock,
            merchants[msg.sender].products[productCode].idx);
    }

    //internal update to sit below individual public calls
    function updateProduct (uint productCode, string description, uint price, uint stock)
    private
    returns (bool success) {

        if (!isValidProduct(productCode, msg.sender)) return false;

        merchants[msg.sender].products[productCode].description = description;
        var beforeVal = merchants[msg.sender].products[productCode].price * merchants[msg.sender].products[productCode].stock;
        merchants[msg.sender].products[productCode].price = price;
        merchants[msg.sender].products[productCode].stock = stock;
        var afterVal = merchants[msg.sender].products[productCode].price * merchants[msg.sender].products[productCode].stock;
        shopGrossValue += beforeVal - afterVal;

        ProductUpdated(msg.sender,
            productCode,
            merchants[msg.sender].products[productCode].idx,
            merchants[msg.sender].products[productCode].description,
            merchants[msg.sender].products[productCode].price,
            merchants[msg.sender].products[productCode].stock);
        return true;
    }

    function updateProductDescription(uint productCode, string description)
    public
    onlyAuthorisedMerchant()
    returns(bool success) {

        return updateProduct(productCode,
                                description,
                                merchants[msg.sender].products[productCode].price,
                                merchants[msg.sender].products[productCode].stock);

    }

    function updateProductPrice(uint productCode, uint price)
    public
    onlyAuthorisedMerchant()
    returns(bool success) {
         return updateProduct(productCode,
                                merchants[msg.sender].products[productCode].description,
                                price,
                                merchants[msg.sender].products[productCode].stock);
    }

    function updateProductStock(uint productCode, uint stock)
    public
    onlyAuthorisedMerchant()
    returns(bool success) {
        return updateProduct(productCode,
                                merchants[msg.sender].products[productCode].description,
                                merchants[msg.sender].products[productCode].price,
                                stock);
    }



    function buyProduct(uint productCode, uint quantity, address merchantAddress)
    public
    payable
    returns(bool success) {

        if (!isValidProduct(productCode, merchantAddress)) throw;

        //enough stock?
        if (merchants[merchantAddress].products[productCode].stock < quantity) throw;

        //have they sent the correct price?
        var costOfSale = merchants[merchantAddress].products[productCode].price * quantity;
        if (msg.value < costOfSale) throw;

        //buy event

        if (!updateProduct(productCode,
                                merchants[merchantAddress].products[productCode].description,
                                merchants[merchantAddress].products[productCode].price,
                                merchants[merchantAddress].products[productCode].stock -= quantity)) throw;

        ProductBought(merchantAddress, productCode, msg.sender, quantity);


        return true;
    }



    //do not allow eth to be sent
    function() payable {
        throw;
    }

}
