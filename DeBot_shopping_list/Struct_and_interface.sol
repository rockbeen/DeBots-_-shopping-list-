pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

struct ProductsSummary{//Brief description of the products
    uint256 paidFor;
    uint256 notPaid;
    uint256 totalSum;
}

struct Product{//structure of the product type
    uint id;
    string name;
    uint count;
    uint64 when_created;
    bool purchased;
    uint cost;
    bool deleted;
}

interface IntarfacesendTransaction{
    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload) external;
    
}

abstract contract HasConstructorWithPubKey {
    constructor(uint pubkey) public {}
}

interface InterfaceProducts {

    function getProductsSummary() external returns (ProductsSummary summary);//get a Summary of Products(paid/ not paid/ total sum)
    function getProductsList() external returns(Product[] ProductsList);//get a list of products
    function addtoList(string name, uint amount) external;//add a product to the list
    function deleteFromList(uint id) external;//delete a product to the list
    function buy(uint id, uint price) external;//buy a product by id for the specified price
    
}

