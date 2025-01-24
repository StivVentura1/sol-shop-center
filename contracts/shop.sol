//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

contract Shop{

    struct Product{
        uint primaryKey;
        string name;
        uint price;
        uint quantity;
        uint category;

    }

    string[] productCategory = ["Smarphone", "Game", "Laptop", "Television"]; // dynamic arr

    Product[] products;

    //external::la funzione è dichiarata external in quanto sara usata solamente all'esterno del nostro contratto
    //view::in quanto dovrà accedere in lettura all array productCategory

    function getCategory() external view returns(string[] memory){
        return productCategory;
    }
    
    //aggiungiamo altre categorie 
    function addCategory(string memory category) external {
        //va aggiunto controllo sui duplicati 
        productCategory.push(category);
    }
    
    //aggiungiamo altri prodotti 
    function addProduct(string memory name, uint price, uint quantity, uint category) external {

        products.push(Product((products.length+1), name, price, quantity, category));
        
    }

    //overloading
    function addProduct(string memory name, uint price, uint quantity, string memory category) external{

        //recupera l id della categoria
        int idCategory = -1;
        for(uint i = 0; i < productCategory.length; i++){
            if(keccak256(abi.encodePacked(productCategory[i])) == keccak256(abi.encodePacked(category))){
                idCategory = int(i);
                break;
            }
        }
        if(idCategory !=1){
            products.push(Product((products.length +1), name,price,quantity, uint(idCategory)));
        }
        
    }
    //ritorna la lista dei prodotti nello store
    //anch'essa dovendo accendere ad una variabile di stato (array products) va qualificata come view
    function getProducts() external view returns(Product[] memory){
        return products;
    }
    //overloading
    //restituisce la lista dei prodotti per categoria::input
    function getProducts(string memory category) external view returns(Product[] memory){
        if(keccak256(abi.encodePacked(category)) == keccak256(abi.encodePacked(""))){
            return products;
        }

        Product[] memory result = new Product[](products.length);
        //recupera l'id categoria
        int idCategory = -1;
        for(uint i = 0; i < productCategory.length; i++){
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

}
