pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Base_Debot.sol";
import "Shopping_List.sol";

contract ShopperDebot is BaseDebot{

    string NameCurrentProduct;

    function menuOutput(ProductsSummary summary) public override{
        Menu.select(ggetSummary(summary), "",
            [
                MenuItem("Add product", "", tvm.functionId(NameProduct)),
                MenuItem("Remove product", "", tvm.functionId(removeProduct)),
                MenuItem("Show shopping list", "", tvm.functionId(showList))
            ]
        );
    }

    function NameProduct(uint32 index) public{
        index = index;
        Terminal.input(tvm.functionId(NumberOfProducts), "Please, enter the product name", false);
    }

    function NumberOfProducts(string name) public{
        NameCurrentProduct = name;
        Terminal.input(tvm.functionId(AddProduct), "Please, specify the number of products", false);
    }

    function AddProduct(string val) public{
        (uint count, bool valid) = stoi(val);
        InterfaceProducts(contractAddr).addToLIst{
            extMsg: true,
            abiVer: 2,
            sign: true,
            pubkey: userPubKey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onProductAdded),
            onErrorId: tvm.functionId(onProductAddError)
        }(NameCurrentProduct, count);
    }

     function onProductAddError(uint32 sdkError, uint32 exitCode) public{
        Terminal.print(0, "Error. Please, try again.");
        NameProduct(0);
    }
    function onProductAdded() public{
        Terminal.print(0, "You have added a new item to your shopping list.");
        showData();
    }

  
    
}