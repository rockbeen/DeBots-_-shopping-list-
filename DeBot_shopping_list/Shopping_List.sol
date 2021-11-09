pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Struct_and_interface.sol";

contract ShoppingList is InterfaceProducts{

    mapping(uint => Product) Products;

    uint ownerPubKey;
    uint IDnewProduc;
  
    modifier onlyOwner(){
        require(msg.pubkey() == ownerPubKey, 200);
        _;
    }

    constructor(uint pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        IDnewProduc = 0;
        ownerPubKey = pubkey;
    }

    

    function addToLIst(string name, uint count) public override onlyOwner{
        tvm.accept();
        IDnewProduc+=1;

        Products[IDnewProduc] = Product(IDnewProduc, name, count, now, false, 0, false);
    }

    function deleteFromList(uint ID) public override onlyOwner{
        require(!Products[ID].deleted, 105);
        if(Products.exists(ID)){

            tvm.accept();
            Products[ID].deleted = true;
        }
    }

    function getProductsList() public override returns(Product[] ProductsList){
        for((uint ID, Product product) : Products) {
            if(!product.deleted){
                ProductsList.push(Product(ID, product.name, product.count, product.when_created, product.purchased, product.cost, false));
            }
       }
    }

    function buy(uint ID, uint price) public override onlyOwner{

        optional(Product) ProductToBuy = Products.fetch(ID);

        require(ProductToBuy.hasValue(), 103);
        require(!Products[ID].deleted, 105);
        tvm.accept();

        Products[ID].cost = price;
        Products[ID].purchased = true;
    }

    function getProductsSummary() public override returns(ProductsSummary summary){
        tvm.accept();
        for((uint ID, Product ProductToBuy) : Products){
            if(!ProductToBuy.deleted){
                if(ProductToBuy.purchased){
                    summary.paidFor += ProductToBuy.count;
                    summary.totalSum += ProductToBuy.cost;} 
                else    {summary.notPaid += ProductToBuy.count;} 
            }
        }   
    }

   
}