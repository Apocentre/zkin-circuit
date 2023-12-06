pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/comparators.circom";

/// Returns  1if the two input values are not equal else 0
template NotEqual() {
  signal input in[2];
  signal output out;

  component isEq = IsEqual();
  isEq.in[0] <== in[0];
  isEq.in[1] <== in[1];

  signal result <-- isEq.out == 1 ? 0 : 1;
  
  out <== result;
}
