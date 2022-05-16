//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    uint256[] leaves; 

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        // tree levels = 3
        for (uint8 i =0; i<8; i++){
            hashes.push(0);
        }
        //all leaves pushed, now calculate merkle root and hashes
        for(uint32 i=0; i<14; i+=2){
            hashes.push(PoseidonT3.poseidon([hashes[i],hashes[i+1]]));
        }
        root = hashes[14];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        require(index<8, "The tree is full");
        hashes[index] = hashedLeaf;
        // uint8 level = 3;//height - 1
        // uint levelPow = 2**3;
        // uint updateIndex = index;
        // uint childIdx = index;
        // hashes[8] = PoseidonT3.poseidon([hashes[0],hashes[1]]);
        // hashes[12] = PoseidonT3.poseidon([hashes[8],hashes[9]]);
        // hashes[14] = PoseidonT3.poseidon([hashes[12],hashes[13]]);
        // full update: 
        // for (uint8 i = 0; i<level; i++){
        //     // if (childIdx%2 == 1){
        //     //     updateIndex += levelPow - 1;
        //     // }else{
        //     //     updateIndex += levelPow;
        //     // }
        //     updateIndex += levelPow - (childIdx%levelPow);

        //     if(childIdx%2 == 1){
        //     hashes[updateIndex] = PoseidonT3.poseidon([hashes[childIdx-1],hashes[childIdx]]);
        //     }else{
        //     hashes[updateIndex] = PoseidonT3.poseidon([hashes[childIdx],hashes[childIdx+1]]);

        //     }
        //     childIdx = updateIndex;
        //     levelPow /= 2;
        // }
        // root = hashes[14];
        // index += 1;
        uint j = 8;
        for(uint32 i=0; i<14; i+=2){

            hashes[j] = PoseidonT3.poseidon([hashes[i],hashes[i+1]]);
            j ++;
        }
        root = hashes[14];
        index += 1;        
        return j;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return (input[0]==root && Verifier.verifyProof(a,b,c, input));
    }
}
