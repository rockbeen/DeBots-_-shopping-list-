pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

struct ProductsSummary{
    uint256 paidFor;
    uint256 notPaid;
    uint256 totalSum;
}

struct Product{
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

    function getProductsSummary() external returns (ProductsSummary summary);
    function getProductsList() external returns(Product[] ProductsList);
    function addToLIst(string , uint ) external;
    function deleteFromList(uint id) external;
    function buy(uint id, uint price) external;
    
}

