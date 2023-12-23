pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";

/// It hashes the modulus i.e. provider public key using poseidon hash
/// This works with a modulus that have 17 items
template Modulus() {
  signal input in[17];
  signal output out;

  signal lhs[16];
  for (var i = 0; i < 16; i++) {
    lhs[i] <== in[i];
  }

  component final_hash = Poseidon(2);
  final_hash.inputs[0] <== Poseidon(16)(lhs);
  final_hash.inputs[1] <== in[16];

  out <== final_hash.out;
}
