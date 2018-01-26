pragma solidity ^0.4.17;

import "./Stopable.sol";

contract Shopfront is Stopable {
  address public shopOwner;
  uint balance;

  struct Product {
    uint id;
    uint price;
    uint stock;
  }

  mapping (uint => Product) products;
  mapping (uint => bool) productExists;
  uint[] public ids;

  //modifier to check that only the shopowner can do certain actions 
  modifier onlyShopOwner{
    if (msg.sender == shopOwner)
    _;
  }

  event LogProductAdded(address sender, uint id, uint price, uint stock);
  event LogStockAdded(address sender, uint id, uint stockAdded);
  event LogProductBought(address buyer, uint id, uint stockLeft);
  event LogWithdrawal(address withdrawer, uint amount);


  function Shopfront(address _shopOwner) {
    // constructor
    shopOwner = _shopOwner;
  }


//add a product to the inventory
function addProduct (uint _id, uint _price, uint _stock)
onlyShopOwner
returns (bool success)
{
  require(_price > 0);
  require (!productExists[_id]);
  products[_id].price = _price * 1 ether;
  products[_id].stock = _stock;
  productExists[_id] = true;
  ids.push(_id);
  return true;
}

//add new stock to a product
function addStock(uint _id, uint _stockAdded)
onlyShopOwner
returns (bool success)
{
require (_stockAdded > 0);
products[_id].stock += _stockAdded;
return true;
}

//should we also create a reduce stock function?

//remove product from inventory
function removeProduct(uint _id)
onlyShopOwner
returns (bool succes){
  products[_id].stock = 0;
  products[_id].price = 0;
  productExists[_id] = false;
  return true;
}


//customer must be able to buy a product
function buyProduct (uint _id)
payable
returns (bool success){
  require(msg.value == products[_id].price);
  require(products[_id].stock > 0);
  products[_id].stock -= 1;
  balance += msg.value;
  return true;
}

//function that allows the shop owner to withdraw the funds in the contract
function withdrawBalance()
onlyShopOwner
returns (bool succes)
{
require (balance > 0);
uint amount = balance;
balance = 0;
msg.sender.transfer(amount);
LogWithdrawal(msg.sender, amount);
return true;
}
}
