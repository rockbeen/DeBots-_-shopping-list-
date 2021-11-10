pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Struct_and_interface.sol";

contract ShoppingList {

    mapping(uint => Product) MapProducts;

    uint ownerPubKey;
    uint IDnewProduc;
  
    modifier onlyOwner(){
        require(msg.pubkey() == ownerPubKey, 150);
        _;
    }

    constructor(uint pubkey) public {
        require(pubkey != 0, 121);
        tvm.accept();
        IDnewProduc = 0;
        ownerPubKey = pubkey;
    }

    

    function addToLIst(string name, uint32 count) public onlyOwner {
        tvm.accept();
        IDnewProduc++;
        MapProducts[IDnewProduc] = Product(IDnewProduc, name, count, now, false, 0,false);
    }

    function deleteFromList(uint ID) public  onlyOwner{
        require(!MapProducts[ID].deleted, 105);
        if(MapProducts.exists(ID)){

            tvm.accept();
            MapProducts[ID].deleted = true;
        }
    }

    function getProductsList() public  returns(Product[] ProductsList){
        for((uint ID, Product product) : MapProducts) {
            if(!product.deleted){
                ProductsList.push(Product(ID, product.name, product.count, product.when_created, product.purchased, product.cost, false));
            }
       }
    }

    function buy(uint ID, uint price) public  onlyOwner{

        optional(Product) ProductToBuy = MapProducts.fetch(ID);

        require(ProductToBuy.hasValue(), 103);
        require(!MapProducts[ID].deleted, 105);
        tvm.accept();

        MapProducts[ID].cost = price;
        MapProducts[ID].purchased = true;
    }

    function getProductsSummary() public returns(ProductsSummary summary){
        tvm.accept();
        for((uint ID, Product ProductToBuy) : MapProducts){
            if(!ProductToBuy.deleted){
                if(ProductToBuy.purchased){
                    summary.paidFor += ProductToBuy.count;
                    summary.totalSum += ProductToBuy.cost;} 
                else    {summary.notPaid += ProductToBuy.count;} 
            }
        }   
    }

   
}