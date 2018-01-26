pragma solidity ^0.4.17;

import "./Shopfront.sol";
import "./Stopable.sol";

contract ShopHub is Stopable {

  address[] public shops;
  mapping(address => bool) shopExists;

  event LogNewShop(address shopOwner, address shop);
  event LogShopClosed(address sender, address shop);
  event LogShopReopened(address sender, address shop);
  event LogShopOwnerChanged(address sender, address newShopOwner);

  //Modifier to check if the shop exists
  modifier onlyIfShop (address shop){
    if(shopExists[shop]) _;
  }

  //function to get the number of shops created by the hub
  function getShopCount()
  public
  constant
  returns (uint numberOfShops) {
    return shops.length;
  }

  //function to create a new shop
  function newShop()
  public
  returns (address  shopContract){
    Shopfront trustedShop = new Shopfront(msg.sender);
    shops.push(trustedShop);
    shopExists[trustedShop] = true;
    LogNewShop(msg.sender,trustedShop);
    return trustedShop;
  }

//pass-through admin controls
  function closeShop(address _shop)
    onlyOwner
    onlyIfShop(_shop)
    returns (bool success)
    {
    Shopfront trustedShop = Shopfront(_shop);
    LogShopClosed(msg.sender, _shop);
    return (trustedShop.runSwitch(false));
  }

  function reopenShop(address _shop)
    onlyOwner
    onlyIfShop(_shop)
    returns (bool success)
    {
    Shopfront trustedShop = Shopfront(_shop);
    LogShopReopened(msg.sender, _shop);
    return (trustedShop.runSwitch(true));
  }

//function seems not to be working
  function changeShopOwner(address _shop, address _newOwner)
    onlyOwner
    onlyIfShop(_shop)
    returns (bool success)
    {
    Shopfront trustedShop = Shopfront(_shop);
    LogShopOwnerChanged(msg.sender, _shop);
    trustedShop.changeOwner(_newOwner);
  }
  }

