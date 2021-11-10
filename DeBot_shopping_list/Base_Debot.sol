pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Struct_and_interface.sol";

import "./base/Terminal.sol";
import "./base/Sdk.sol";
import "./base/AddressInput.sol";
import "./base/ConfirmInput.sol";
import "./base/Debot.sol";
import "./base/Menu.sol";

abstract contract BaseDebot is Debot{

    uint userPubKey;
    bytes iconPath;
    
    address contractAddr;
    address creationAcc;
    
    TvmCell contractStateInit;
    uint32 INITIAL_BALANCE =  200000000;
    
    function menuOutput(ProductsSummary summary) virtual public;

    function start() public override{
        Terminal.input(tvm.functionId(savePublicKey),"Hello, I'm Debot! Please enter your public key",false);
    }

    function setContract(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        contractStateInit = tvm.buildStateInit(code, data);
    }

    function savePublicKey(string value) public {
        (uint res, bool valid) = stoi("0x"+value);
        if(valid) {
            userPubKey = res;
            Terminal.print(0, "Checking if you already have a Debot 'Shopping list'. Please wait ...");
            TvmCell deployState = tvm.insertPubkey(contractStateInit, userPubKey);
            contractAddr = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format( "Info: your Debot 'Shopping list' contract address is: {}", contractAddr));
            Sdk.getAccountType(tvm.functionId(checkAccountType), contractAddr);
        } else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }

    function checkAccountType(int8 acc_type) public {
        if(acc_type == 1) { 
            Terminal.print(0, "Your account is ready");
            showData();
        }else if(acc_type == -1)  { 
            Terminal.print(0, "You don't have a Debot 'Shopping list' yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign two transactions.");
        }else if(acc_type == 0) { 
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your Debot 'Shopping list' contract has enough tokens on its balance."
            ));
            deploy();
        }else if(acc_type == 2) {  
            Terminal.print(0, format("Can not continue: account {} is frozen", contractAddr));
        }
    }

    function creditAccount(address value) public {
        creationAcc = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        IntarfacesendTransaction(creationAcc).sendTransaction{
            extMsg: true,
            abiVer: 2,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeCredit),
            onErrorId: tvm.functionId(CreditError)
        }(contractAddr, INITIAL_BALANCE, false, 3, empty);
    }

    function CreditError(uint32 sdkError, uint32 exitCode) public{
        ConfirmInput.get(tvm.functionId(CreditErrorTryAgain), "Error. Please, check your wallet balance. Do you want to try again?");
    }

    function CreditErrorTryAgain(bool tryAgain) public{
            if(tryAgain){
            creditAccount(creationAcc);
        }else{
            start();
        }
        
    }

    function deploy() private view {
        TvmCell image = tvm.insertPubkey(contractStateInit, userPubKey);
        optional(uint256) none;
        TvmCell deployMsg = tvm.buildExtMsg({
            abiVer: 2,
            dest: contractAddr,
            callbackId: tvm.functionId(DeploySuccess),
            onErrorId:  tvm.functionId(DeployError),    
            time: 0,
            expire: 0,
            sign: true,
            pubkey: none,
            stateInit: image,
            call: {HasConstructorWithPubKey, userPubKey}
        });
        tvm.sendrawmsg(deployMsg, 1);
    }

    function DeployError() public{
        ConfirmInput.get(tvm.functionId(DeployErrorTryAgain), "Error. Please, check your wallet balance. Do you want to try again?");
    }

    function DeploySuccess() public {
        showData();
    }

    function waitBeforeCredit() public  {
        Sdk.getAccountType(tvm.functionId(checkIfContractHasBalance), contractAddr);
    }

    function DeployErrorTryAgain(bool tryAgain) public{
          if(tryAgain){
            deploy();
        }else{
            start();
        }
         
    }
    function checkIfContractHasBalance(int8 acc_type) public {
         if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeCredit();
        }
    
    }

    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Shopping list";
        version = "0.2.0";
        publisher = "Drozhbin Kirill";
        caption = "Shopping list ";
        author = "Drozhbin Kirill";
        support = address.makeAddrStd(0, 0x67aac015fcac6b2c3d045fa14110d27dc4f7859e2a2341610d94d510d99a068c);
        hello = "Hi, i'm a DeBot 'Shopping list'.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = iconPath;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }


    

    function getSummary(ProductsSummary summary) internal returns(string){
        return format(
                "You have {}/{}/{} (Number of products purchased/Number of products not purchased/Total price of products)",summary.paidFor, summary.notPaid,summary.totalSum
            );
    }



    function showList(uint32 index) public{
        index = index;
        optional(uint256) none;
        InterfaceProducts(contractAddr).getProductsList{
            extMsg: true,
            abiVer: 2,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(_showList),
            onErrorId: tvm.functionId(showListError)
        }();
    }

     function showListError(uint32 sdkError, uint32 exitCode) public{
        Terminal.print(0, "Error. Try again.");
        showData();
    }

    function _showList(Product[] ProductsList) public{
        printList(ProductsList);
    }
    function printList(Product[] ProductsList) internal{
        if (ProductsList.length != 0){
            string list = "";
            for(uint i = 0; i < ProductsList.length; i++){
                Product Product = ProductsList[i];
                string name = ProductsList[i].name;
                string buy;
                uint id = Product.id;
                if(Product.purchased) buy = "✔";
                else buy = " ";  
                Terminal.print(0, format("{}. {} {}", id, name, buy));
            }
            showData();
        } else
        {
            Terminal.print(0, "There is not a single item on your shopping list.");
            showData();
        }
    }
   

    function removeProduct(uint32 index) public{
        Terminal.input(tvm.functionId(_removeProduct), "Please enter the product ID to delete.", false);
    }

    function _removeProduct(string value) public{
        (uint id, bool valid) = stoi(value);
        if(!valid){
            DeleteError(0, 0);
            return;
        } 
        InterfaceProducts(contractAddr).deleteFromList{
            extMsg: true,
            abiVer: 2,
            sign: true,
            pubkey: userPubKey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(successfullyDeletedProduct),
            onErrorId: tvm.functionId(DeleteError)
        }(id);
    }

    function successfullyDeletedProduct() public{
        Terminal.print(0, "This product has been removed.");
        showData();
    }

  

    function DeleteError(uint32 sdkError, uint32 exitCode) public{
        Terminal.print(0, "Error.Try another id");
        showData();
    }

   
    function showData() public {
        optional(uint256) none;
        InterfaceProducts(contractAddr).getProductsSummary{
            extMsg: true,
            abiVer: 2,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(menuOutput),
            onErrorId: tvm.functionId(showDataError) 
        }();
    }

    function showDataError(uint32 sdkError, uint32 exitCode) public{
        Terminal.print(0, "Error. Some error occurred while displaying the summary.");
        showData();
    }

   


}