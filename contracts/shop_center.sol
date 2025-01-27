//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Shop is Ownable{

    struct Product{
        uint primaryKey;
        string name;
        uint price;
        uint quantity;
        uint category;

    }

    string[] productCategory = ["Smartphone", "Game", "Laptop", "Television"]; // dynamic array per il catalogo dei prodotti

    Product[] products;
    constructor(address initialOwner) Ownable(initialOwner){
            
    }
    /*constructor(){
        for(uint i = 0; i < productCategory.length; i++){
            addCategory[productCategory[i]] = (i +1);
        }
    }*/

    //ritorna l id della categoria
    function getIdCategory(string memory category) private view returns(int){

        for(uint256 i =0; i< productCategory.length;i++){
            if(keccak256(abi.encodePacked(productCategory[i])) == keccak256(abi.encodePacked(category))){
                return int(i);
            }

        }
        return -1;
    }
    //external::la funzione è dichiarata external in quanto sara usata solamente all'esterno del nostro contratto
    //view::in quanto dovrà accedere in lettura all array productCategory
    function getCategory() external view returns(string[] memory){
        return productCategory;
    }
    //aggiungiamo altre categorie 
    function addCategory(string memory category) external{
        
        //recupera l id della categoria
        int idCategory = getIdCategory(category);
        //va aggiunto controllo sui duplicati 
        if(idCategory ==-1)
        productCategory.push(category);
    }
    
    //aggiungiamo altri prodotti 
    function addProduct(string memory name, uint price, uint quantity, uint category) external onlyOwner {

        require(category < products.length);
        products.push(Product(products.length+1, name, price, quantity, category));
        
    }

    //overloading
    function addProduct(string memory name, uint price, uint quantity, string memory category) external onlyOwner {
        
        //recupera l id della categoria
        int IdCategory = getIdCategory(category);
        if(IdCategory !=-1) {
            products.push(Product(products.length +1, name, price, quantity, uint(IdCategory)));

        }
         
    }
        
    //ritorna la lista dei prodotti nello store
    //anch'essa dovendo accendere ad una variabile di stato (array products) va qualificata come view
    function getProducts() public view returns(Product[] memory){
        return products;
    }
    //overloading
    //restituisce la lista dei prodotti per categoria::input
    function getProducts(string memory category) external view returns(Product[] memory){
        //verifica se l'utente inserisce una categoria
        if(keccak256(abi.encodePacked(category)) == keccak256(abi.encodePacked(""))){
            return getProducts();
        }

        Product[] memory result = new Product[](products.length);
        //recupera l'id categoria
        int idCategory = -1;
       for(uint i = 0 ;i < productCategory.length; i++){
            if(keccak256(abi.encodePacked(productCategory[i])) == keccak256(abi.encodePacked(category))){
            idCategory = int(i);
            
            break;
            }
        }
        if(idCategory == -1)
        return result;

        uint index = 0;
        for(uint i = 0; i < products.length; i++){
            if(products[i].category == uint(idCategory)){
                result[index] = products[i];

                index++;
            }
        }
        return result;
    }
    function search(string memory name) internal view returns(Product storage){
        for(uint i= 0; i< products.length; i++){
            if(keccak256(abi.encodePacked(products[i].name)) == keccak256(abi.encodePacked(name)))
                return products[i];
        
        }
        //in caso di ""null"" revert fa abortire la chiamata a questa funzione annullando la transazione comprese le gas fee
        //ma i costi relativi all esecuzine verranno comunque addebitati al utente chiamante
        revert("Product not found");
    
    }


    function searchProduct(string calldata name)external view returns(Product memory){
        return search(name);
    }
    //goldie
    function buyProduct(string memory name, uint quantity) external payable {
        
        //carca il prodotto
        Product storage product = search(name);

        //verifichiamo la qty in "magazzino"
        require(product.quantity >= quantity, "insufficent qunatity");
       /*if(product.quantity < quantity){
            revert("insufficent quantity");
        }*/
        //verifica del prezzo
        require((product.price * quantity) != msg.value, "incorrect or insufficent funds" );
        /*if((product.price * quantity ) != msg.value){
            revert("incorrect or insufficent funds");
        }*/
        //se si arriva a questo punto la transazione può essere conclusa
        product.quantity -= quantity;
    }

}
