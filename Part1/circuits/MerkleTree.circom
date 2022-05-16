pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    signal intermediateHashes [2**n-1];
    var readIndex = 0;
    var writeIndex = 0;
    component hashArr[2**n - 1];
    var hasherIdx = 0;

    // initailize all hashers
    for (var i=0; i<2**n-1; i++){
        hashArr[i] = Poseidon(2);
    }

    // populate first half of intermidate from leaves
    for (var i = 0; i<2**n; i+=2){
        hashArr[hasherIdx].inputs[0] <== leaves[i];
        hashArr[hasherIdx].inputs[1] <== leaves[i+1];
        intermediateHashes[writeIndex] <== hashArr[hasherIdx].out;
        writeIndex++;
        hasherIdx++;
    }
    
    // populate 2nd half of hash arr
    while(writeIndex<2**n-1){
        hashArr[hasherIdx].inputs[0] <== intermediateHashes[readIndex];
        hashArr[hasherIdx].inputs[1] <== intermediateHashes[readIndex+1];
        intermediateHashes[writeIndex] <== hashArr[hasherIdx].out;
        readIndex += 2;
        writeIndex++;
        hasherIdx++;
    }

    root <== intermediateHashes[writeIndex-1];
}


template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hashArr[2*n];
    signal intermediateHashes[n];

    component muxArr[n];

    // initialize hashers and comparators
    for (var i=0; i<2*n; i++){
        hashArr[i] = Poseidon(2);
        if (i<n){
            muxArr[i] = Mux1();
        }
    }

    // calculate all the hashes and check
    
    hashArr[0].inputs[0] <== leaf;
    hashArr[0].inputs[1] <== path_elements[0];

    hashArr[1].inputs[0] <== path_elements[0];
    hashArr[1].inputs[1] <== leaf;

    muxArr[0].c[0] <== hashArr[0].out;
    muxArr[0].c[1] <== hashArr[1].out;
    muxArr[0].s <== path_index[0];
    
    intermediateHashes[0] <== muxArr[0].out;
    
    //
    for (var i=1; i<n; i++){
        hashArr[2*i].inputs[0] <== intermediateHashes[i-1];
        hashArr[2*i].inputs[1] <== path_elements[i];

        hashArr[2*i + 1].inputs[0] <== path_elements[i];
        hashArr[2*i + 1].inputs[1] <== intermediateHashes[i-1];

        muxArr[i].c[0] <== hashArr[2*i].out;
        muxArr[i].c[1] <== hashArr[2*i + 1].out;
        muxArr[i].s <== path_index[i];
    
        intermediateHashes[i] <== muxArr[i].out;
    }

    root <== intermediateHashes[n-1];
}