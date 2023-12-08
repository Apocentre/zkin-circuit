pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";

// Checks that a€[low, high] is
template Range(N) {
  signal input a;
  signal input low;
  signal input high;

  signal output out;

  component gt = GreaterEqThan(N);
  gt.in[0] <== a;
  gt.in[1] <== low;

  component lt = LessEqThan(N);
  lt.in[0] <== a;
  lt.in[1] <== high;

  // we can optionally return. This will work only if a is in range. Otherwise witness generation will fail in the line above.
  out <== gt.out * lt.out;
}
