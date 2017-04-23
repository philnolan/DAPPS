pragma solidity ^ 0.4 .0;


//shopKeeper is master merchant
//products

contract ShopKeeper {

    uint constant shopOwnerMerchantCode = 0;
    uint public merchantCount;

    //address shopOwner;
    modifier onlyMerchantOwner(uint merchantCode) {
        if (msg.sender != merchants[merchantCode].Address) throw;
        _;
    }

    modifier onlyShopOwner() {
        if (msg.sender != merchants[shopOwnerMerchantCode].Address) throw;
        _;
    }

   struct Product {
        string description;
        uint price;
        uint stock;
        uint idx;
    }

    enum MerchantStatus {AwaitingApproval, Rejected, Authorised}
    //modifier atStatus(MerchantStatus status, MerchantStatus _hasToBeStatus) {
    //    if (status != hasToBeStatus) throw;
    //    _;
    //}

    struct Merchant {
        address Address;
        string Name;
        MerchantStatus Status;
        uint ProductCount;
        uint Value;
        uint idx;
        mapping(uint => Product) products;
        uint[] productsIndex;
    }
    mapping(uint => Merchant) merchants;
    uint[] merchantsIndex;



    uint public shopGrossValue;

    event MerchantAdded(uint indexed merchantCode, string name, address addr);
    event MerchantAuthorised(uint indexed merchantCode);
    event MerchantRejected(uint indexed merchantCode);


    event ProductAdded(uint indexed merchantCode, uint indexed productCode, uint idx, string description, uint price, uint stock);
    event ProductUpdated(uint indexed merchantCode, uint indexed productCode, uint idx, string description, uint price, uint stock);
    event ProductDeleted(uint indexed merchantCode, uint indexed productCode, uint idx);
    event ProductBought(uint indexed merchantCode, uint indexed productCode, address indexed buyer, uint quantity);

    function ShopKeeper() {
        //shopOwner = msg.sender;

        merchants[shopOwnerMerchantCode].Address = msg.sender;
        merchants[shopOwnerMerchantCode].Name = "shopOwner";
        merchants[shopOwnerMerchantCode].Status = MerchantStatus.Authorised;
        //merchants[shopOwnerMerchantCode].idx = merchantCount;
        merchantCount++;
    }

    //////Start:  Merchant functions//////
    function getProductAtIndexForMerchant(uint idx, uint merchantCode)
    public
    constant
    returns(uint productCode) {
        return merchants[merchantCode].productsIndex[idx];
    }

    function addMerchant(uint merchantCode, string name )
    public
    payable
    {
        //test to make sure address is not already in use
        //and the code isn't used by keeper
        if (merchants[merchantCode].idx != 0) throw;
        if (merchantCode == shopOwnerMerchantCode) throw;

        //should shop owner add merchant codes?
        merchants[merchantCode].Address = msg.sender;

        merchants[merchantCode].Name = name;
        merchants[merchantCode].Status = MerchantStatus.AwaitingApproval;
        merchants[merchantCode].idx = merchantCount;

        //pay to be included?
        merchants[merchantCode].Value = msg.value;

        merchantCount++;

        MerchantAdded(merchantCode, name, msg.sender);
    }

    function authoriseMerchant(uint merchantCode)
    public
    onlyShopOwner
    returns (bool success)
    {
        if (merchants[merchantCode].idx != 0) return false;
        if (merchantCode == shopOwnerMerchantCode) return false;
        if ( merchants[merchantCode].Status == MerchantStatus.Authorised)  return false;

        merchants[merchantCode].Status = MerchantStatus.Authorised;
        MerchantAuthorised(merchantCode);
        return true;
    }

    function rejectMerchant(uint merchantCode)
    public
    onlyShopOwner
    returns (bool success) {
        if (merchants[merchantCode].idx != 0) return false;
        if (merchantCode == shopOwnerMerchantCode) return false;
        if ( merchants[merchantCode].Status == MerchantStatus.Rejected)  return false;

        merchants[merchantCode].Status = MerchantStatus.Rejected;
        MerchantRejected(merchantCode);
        return true;
    }

    function getNumberOfMerhcants()
    public
    constant
    returns (uint count)
    {
        return merchantsIndex.length;
    }

    function getProductCountForMerchant(uint merchantCode)
    public
    constant
    returns(uint count) {
        return merchants[merchantCode].productsIndex.length;
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
        suicide(merchants[shopOwnerMerchantCode].Address);
        return true;
    }
    //////End:  Merchant functions//////

    //////Start:  Product functions//////

    function isValidProduct(uint productCode, uint merchantCode)
    internal
    constant
    returns(bool isValid) {
        if (merchants[merchantCode].productsIndex.length == 0) return false;
        uint idx = merchants[merchantCode].products[productCode].idx;
        return (merchants[merchantCode].productsIndex[idx] == productCode);
    }


    function addProduct(uint productCode, string description, uint price, uint stock, uint merchantCode)
    onlyMerchantOwner(merchantCode)
    returns(bool success) {
        if (isValidProduct(productCode, merchantCode)) return false;
        if (merchants[merchantCode].Status != MerchantStatus.Authorised) return false;

        merchants[merchantCode].products[productCode].description = description;
        merchants[merchantCode].products[productCode].price = price;
        merchants[merchantCode].products[productCode].stock = stock;
        merchants[merchantCode].products[productCode].idx = merchants[merchantCode].productsIndex.push(productCode) - 1;
        shopGrossValue += price * stock;
        merchants[merchantCode].ProductCount++;
        ProductAdded(merchantCode,
            productCode,
            merchants[merchantCode].products[productCode].idx,
            description,
            price,
            stock);
        return true;
    }

    function deleteProduct(uint productCode, uint merchantCode)
    public
    onlyMerchantOwner(merchantCode)
    returns(bool success) {
        if (!isValidProduct(productCode, merchantCode)) return false;
        if (merchants[merchantCode].Status != MerchantStatus.Authorised) return false;

        uint idxProductToDelete = merchants[merchantCode].products[productCode].idx;
        uint productCodeToShift = merchants[merchantCode].productsIndex[merchants[merchantCode].productsIndex.length - 1];

        shopGrossValue -= merchants[merchantCode].products[productCode].price * merchants[merchantCode].products[productCode].stock;

        merchants[merchantCode].productsIndex[idxProductToDelete] = productCodeToShift;
        merchants[merchantCode].products[productCodeToShift].idx = idxProductToDelete;

        merchants[merchantCode].productsIndex.length--;
        ProductDeleted(merchantCode,
            productCode,
            idxProductToDelete);

        return true;
    }

    function getProduct(uint productCode, uint merchantCode)
    public
    constant
    returns(string description, uint price, uint stock, uint idx) {
        if (!isValidProduct(productCode, merchantCode)) throw;
        return (
            merchants[merchantCode].products[productCode].description,
            merchants[merchantCode].products[productCode].price,
            merchants[merchantCode].products[productCode].stock,
            merchants[merchantCode].products[productCode].idx);
    }

    //internal update to sit below individual public calls
    function updateProduct (uint productCode, string description, uint price, uint stock, uint merchantCode)
    private
    returns (bool success) {

        if (!isValidProduct(productCode, merchantCode)) return false;
        if (merchants[merchantCode].Status != MerchantStatus.Authorised) return false;

        merchants[merchantCode].products[productCode].description = description;
        var beforeVal = merchants[merchantCode].products[productCode].price * merchants[merchantCode].products[productCode].stock;
        merchants[merchantCode].products[productCode].price = price;
        merchants[merchantCode].products[productCode].stock = stock;
        var afterVal = merchants[merchantCode].products[productCode].price * merchants[merchantCode].products[productCode].stock;
        shopGrossValue += beforeVal - afterVal;

        ProductUpdated(merchantCode,
            productCode,
            merchants[merchantCode].products[productCode].idx,
            merchants[merchantCode].products[productCode].description,
            merchants[merchantCode].products[productCode].price,
            merchants[merchantCode].products[productCode].stock);
        return true;
    }

    function updateProductDescription(uint productCode, string description, uint merchantCode)
    public
    onlyMerchantOwner(merchantCode)
    returns(bool success) {

        return updateProduct(productCode,
                                description,
                                merchants[merchantCode].products[productCode].price,
                                merchants[merchantCode].products[productCode].stock,
                                merchantCode);

    }

    function updateProductPrice(uint productCode, uint price, uint merchantCode)
    public
    onlyMerchantOwner(merchantCode)
    returns(bool success) {
         return updateProduct(productCode,
                                merchants[merchantCode].products[productCode].description,
                                price,
                                merchants[merchantCode].products[productCode].stock,
                                merchantCode);
    }

    function updateProductStock(uint productCode, uint stock, uint merchantCode)
    public
    onlyMerchantOwner(merchantCode)
    returns(bool success) {
        return updateProduct(productCode,
                                merchants[merchantCode].products[productCode].description,
                                merchants[merchantCode].products[productCode].price,
                                stock,
                                merchantCode);
    }



    function buyProduct(uint productCode, uint quantity, uint merchantCode)
    public
    payable
    returns(bool success) {

        if (!isValidProduct(productCode, merchantCode)) throw;

        //enough stock?
        if (merchants[merchantCode].products[productCode].stock < quantity) throw;

        //have they sent the correct price?
        var costOfSale = merchants[merchantCode].products[productCode].price * quantity;
        if (msg.value < costOfSale) throw;

        //buy event

        if (!updateProduct(productCode,
                                merchants[merchantCode].products[productCode].description,
                                merchants[merchantCode].products[productCode].price,
                                merchants[merchantCode].products[productCode].stock -= quantity,
                                merchantCode)) throw;

        ProductBought(merchantCode, productCode, msg.sender, quantity);


        return true;
    }



    //do not allow eth to be sent
    function() payable {
        throw;
    }

}
