pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/binsum.circom";

template Adder(N) {
  signal input a;
  signal input b;
  signal output out;

  component n2ba = Num2Bits(N);
  component n2bb = Num2Bits(N);
  component sum = BinSum(N, 2);
  component b2n = Bits2Num(N);

  n2ba.in <== a;
  n2bb.in <== b;

  for (var i = 0; i < N; i++) {
    sum.in[0][i] <== n2ba.out[i];
    sum.in[1][i] <== n2bb.out[i];
    b2n.in[i] <== sum.out[i];
  }

  out <== b2n.out;
}
