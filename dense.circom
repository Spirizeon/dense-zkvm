pragma circom 2.1.6;
include "circomlib/poseidon.circom";
include "circomlib/comparators.circom";

// simple Merkle verify for small depth
template MerkleVerify(depth) {
    signal input leaf;
    signal input pathElements[depth];
    signal input pathIndex[depth];
    signal output root;

    var hash = leaf;
    for (var i=0; i<depth; i++){
        var left  = pathIndex[i] == 0 ? hash : pathElements[i];
        var right = pathIndex[i] == 0 ? pathElements[i] : hash;
        component h = Poseidon(2);
        h.inputs[0] <== left;
        h.inputs[1] <== right;
        hash <== h.out;
    }
    root <== hash;
}

// 6-ISA ZKVM
template SimpleZKVM_WASM(n, DEPTH) {
    var NOP      = 0;
    var PUSH     = 1;
    var ADD      = 2;
    var MUL      = 3;
    var SUB      = 4;
    var MERKLE   = 5;
    var NULLIFY  = 6;

    signal input instr[2*n];
    signal input merkleLeaf;
    signal input merklePath[DEPTH];
    signal input merkleIndex[DEPTH];
    signal input nullifierSecret;
    signal input nullifierContext;

    signal output stack[n][n];
    signal output sp[n+1];

    sp[0] <== 0;

    component nullifier = Poseidon(2);
    nullifier.inputs[0] <== nullifierSecret;
    nullifier.inputs[1] <== nullifierContext;

    component merkle = MerkleVerify(DEPTH);
    merkle.leaf <== merkleLeaf;
    for(var d=0; d<DEPTH; d++){
        merkle.pathElements[d] <== merklePath[d];
        merkle.pathIndex[d] <== merkleIndex[d];
    }

    for(var i=0; i<n; i++){
        var op = instr[2*i];
        var arg = instr[2*i + 1];

        signal isPush     <== IsEqual()([op,PUSH]);
        signal isAdd      <== IsEqual()([op,ADD]);
        signal isMul      <== IsEqual()([op,MUL]);
        signal isSub      <== IsEqual()([op,SUB]);
        signal isMerkle   <== IsEqual()([op,MERKLE]);
        signal isNullify  <== IsEqual()([op,NULLIFY]);
        signal isNop      <== IsEqual()([op,NOP]);

        sp[i+1] <== sp[i] + isPush - (isAdd + isMul + isSub);

        for(var j=0;j<n;j++){
            signal val <== stack[i][j];
            val <== val + isPush * (j==sp[i]? arg : 0);
            val <== val + isAdd * (j==sp[i]-2? stack[i][sp[i]-2]+stack[i][sp[i]-1] : 0);
            val <== val + isMul * (j==sp[i]-2? stack[i][sp[i]-2]*stack[i][sp[i]-1] : 0);
            val <== val + isSub * (j==sp[i]-2? stack[i][sp[i]-2]-stack[i][sp[i]-1] : 0);
            val <== val + isMerkle * (j==sp[i]-1? merkle.root : 0);
            val <== val + isNullify * (j==sp[i]-1? nullifier.out : 0);
            stack[i+1][j] <== val;
        }
    }
}

component main = SimpleZKVM_WASM(8,8);
