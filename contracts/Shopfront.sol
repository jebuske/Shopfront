pragma solidity ^0.4.17;

import "./Stopable.sol";

contract Shopfront is Stopable {
  address public shopOwner;
  uint accountTotal;

  struct Product {
    uint price;
    uint stock;
    uint index;
  }

  mapping (uint => Product) private products;
  uint[] private ids;

  //modifier to check that only the shopowner can do certain actions 
  modifier onlyShopOwner{
    if (msg.sender == shopOwner)
    _;
  }

  event LogProductAdded(address sender, uint id, uint index, uint price, uint stock);
  event LogStockAdded(address sender, uint id, uint newStock);
  event LogProductBought(address buyer, uint id, uint stockLeft);
  event LogWithdrawal(address withdrawer, uint amount);
  event LogProductDeleted(address sender, uint id);


  function Shopfront(address _shopOwner) {
    // constructor
    shopOwner = _shopOwner;
  }

//check if product already exists
function isProduct(uint _id)
 public
 constant
 returns(bool isProduct)
{
if(ids.length == 0) return false;
 return (ids[products[_id].index] == _id);
}

//add a product to the inventory
function addProduct (uint _id, uint _price, uint _stock)
onlyShopOwner
returns (bool success)
{
  require(_price > 0);
  require (!isProduct(_id));
  products[_id].price = _price * 1 ether;
  products[_id].stock = _stock;
  products[_id].index = ids.push(_id)-1;
  LogProductAdded(msg.sender, _id, products[_id].index, _price, _stock);
  return true;
}

//getter function 
function getProductAtIndex(uint index) 
  public 
  constant 
  returns(uint id) 
{
  return ids[index];
}

//add new stock to a product
function addStock(uint _id, uint _stockAdded)
onlyShopOwner
returns (bool success)
{
require (isProduct(_id));
require (_stockAdded > 0);
products[_id].stock += _stockAdded;
LogStockAdded(msg.sender, _id, products[_id].stock);
return true;
}

//should we also create a reduce stock function?

//remove product from inventory
function removeProduct(uint _id)
onlyShopOwner
returns (bool succes){
  require (isProduct(_id));
  uint rowToDelete = products[_id].index;
  uint idToMove = ids[ids.length - 1];
  ids[rowToDelete] = idToMove;
  products[idToMove].index = rowToDelete;
  ids.length -- ;
  delete products[_id];
  LogProductDeleted(msg.sender, _id);
  return true;
}


//customer must be able to buy a product
function buyProduct (uint _id)
payable
returns (bool success){
  require(msg.value == products[_id].price);
  require(products[_id].stock > 0);
  products[_id].stock -= 1;
  accountTotal += msg.value;
  LogProductBought(msg.sender, _id, products[_id].stock);
  return true;
}

//function that allows the shop owner to withdraw the funds in the contract
function withdrawBalance()
onlyShopOwner
returns (bool succes)
{
require (accountTotal > 0);
uint amount = accountTotal;
accountTotal = 0;
msg.sender.transfer(amount);
LogWithdrawal(msg.sender, amount);
return true;
}
}
