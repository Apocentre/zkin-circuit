pragma circom 2.1.6;

// TODO: Check the Num2Bits circuit. Maybe there is a simpler way to do shift operations.

include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/sha256/shift.circom";
include "circomlib/circuits/gates.circom";

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

template And(n) {
  signal input a;
  signal input b;
  signal output out;

  // convert num to bits
  component n2b_a = Num2Bits(n);
  n2b_a.in <== a;
  component n2b_b = Num2Bits(n);
  n2b_b.in <== b;
  
  signal result[n];
  component and[n];

  // logical and on each bit
  for (var i = 0; i < n; i++) {
    and[i] = AND();
    and[i].a <== n2b_a.out[i];
    and[i].b <== n2b_b.out[i];

    result[i] <== and[i].out;
  }

  // convert back to number
  component b2n = Bits2Num(n);
  for (var i = 0; i < n; i++) {
    b2n.in[i] <== result[i];
  }

  out <== b2n.out;
}

template Or(n) {
  signal input a;
  signal input b;
  signal output out;

  // convert num to bits
  component n2b_a = Num2Bits(n);
  n2b_a.in <== a;
  component n2b_b = Num2Bits(n);
  n2b_b.in <== b;
  
  signal result[n];
  component and[n];

  // logical and on each bit
  for (var i = 0; i < n; i++) {
    and[i] = OR();
    and[i].a <== n2b_a.out[i];
    and[i].b <== n2b_b.out[i];

    result[i] <== and[i].out;
  }

  // convert back to number
  component b2n = Bits2Num(n);
  for (var i = 0; i < n; i++) {
    b2n.in[i] <== result[i];
  }

  out <== b2n.out;
}
