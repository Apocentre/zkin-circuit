pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/sha256/shift.circom";

template RightShift(n, r) {
  signal input num;
  signal output out;

  // convert num to bits
  component n2b = Num2Bits(n);
  n2b.in <== num;
  
  // shift right
  component shr = ShR(n, r);
  for (var i = 0; i < n; i++) {
    shr.in[i] <== n2b.out[i];
  }

  // convert back to number
  component b2n = Bits2Num(n);
  for (var i = 0; i < n; i++) {
    b2n.in[i] <== shr.out[i];
  }

  out <== b2n.out;
}

template LeftShift(n, r) {
  signal input num;
  signal output out;

  // convert num to bits
  component n2b = Num2Bits(n);
  n2b.in <== num;
  
  // shift left
  component shr = LhR(n, r);
  for (var i = 0; i < n; i++) {
    shr.in[i] <== n2b.out[i];
  }

  // convert back to number
  component b2n = Bits2Num(n);
  for (var i = 0; i < n; i++) {
    b2n.in[i] <== shr.out[i];
  }

  out <== b2n.out;
}

/// This is similar to ShR from the Circomlib
template LhR(n, r) {
  signal input in[n];
  signal output out[n];

  for (var i = n - 1; i >= 0; i--) {
    if (i >= r) {
      out[i] <== in[i - r];
    } else {
      out[i] <== 0;
    }
  }
}

