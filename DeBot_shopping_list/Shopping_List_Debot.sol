pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Base_Debot.sol";

contract Shopping_ListDebot is BaseDebot{


    uint  IDpurchased;

    function menuOutput(ProductsSummary summary) public override{
        string shoppingSummary = getSummary(summary);
        Menu.select(shoppingSummary, "",
            [
                MenuItem("Buy product that are in the shopping list", "", tvm.functionId(buyProductName)),
                MenuItem("Remove a product from the shopping list", "", tvm.functionId(removeProduct)),
                MenuItem("Show my shopping list", "", tvm.functionId(showList))
            ]
        );
    }

    function buyProductName(uint32 index) public{
        index = index;
        Terminal.input(tvm.functionId(buyProductSize), "Please, enter the product ID to purchase", false);
    }

    function buyProductSize(string value) public{
        (uint id, bool valid) = stoi(value);
        IDpurchased = id;
        Terminal.input(tvm.functionId(buyProduct), "Please, enter the price for this item", false);
    }

    function buyProduct(string value) public{ 
        (uint cost, bool valid) = stoi(value);
        InterfaceProducts(contractAddr).buy{
            extMsg: true,
            abiVer: 2,
            sign: true,
            pubkey: userPubKey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(purchasedSuccessfully),
            onErrorId: tvm.functionId(purchaseError)
        }(IDpurchased, cost);
    }
    
    function purchaseError(uint32 sdkError, uint32 exitCode) public{
        Terminal.print(0, "Error. Please, try again.");
        buyProductName(0);
    }

    function purchasedSuccessfully() public{
        Terminal.print(0, "You bought the product.");
        showData();
    }

 

}