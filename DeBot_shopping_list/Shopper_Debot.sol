pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Base_Debot.sol";
import "Shopping_List.sol";

contract ShopperDebot is BaseDebot{

    string NameCurrentProduct;
   

    function menuOutput(ProductsSummary summary) public override{
        Menu.select(getSummary(summary), "",
            [
                MenuItem("Add product ", "", tvm.functionId(AddProductName)),
                MenuItem("Remove produc ", "", tvm.functionId(removeProduct)),
                MenuItem("Show shopping list ", "", tvm.functionId(showList))
            ]
        );
    }

    function AddProductName(uint32 index) public{
        index = index;
        Terminal.input(tvm.functionId(AddProductsNumder), "Please, enter the product name", false);
    }

    function AddProductsNumder(string value) public{
        NameCurrentProduct = value;
        Terminal.input(tvm.functionId(AddProduct), "Please, specify the number of products", false);
    }

    function AddProduct(string value) public {
        (uint amount, bool valid) = stoi(value); 
        InterfaceProducts(contractAddr).addtoList{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: userPubKey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(ProductAdded),
                onErrorId: tvm.functionId(ProductAddError)
            }(NameCurrentProduct, amount);
    }

    
      

    function ProductAddError(uint32 sdkError, uint32 exitCode) public{
        Terminal.print(0, "Error. Please, try again.");
        AddProductName(0);
    }
    function ProductAdded() public{
        Terminal.print(0, "You have added a new item to your shopping list.");
        showData();
    }

  
    
}