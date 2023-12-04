pragma circom 2.1.6;

template Range(N) {
  signal input a;
  signal input low;
  signal input high;

  signal output out;

  component gt = GreaterThan(N);
  gt.in[0] <== a;
  gt.in[1] <== low;

  component lt = LessThan(N);
  lt.in[0] <== a;
  lt.in[1] <== high;

  // Add constraint to make sure a in in range.
  // GreaterThan return 1 if in[0] is greater (of smaller than in case of LessThan) than in[1].
  // If both are 1 then a is the provided range.
  1 === gt.out * lt.out;

  // we can optionally return. This will work only if a is in range. Otherwise witness generation will fail in the line above.
  out <== gt.out * lt.out;
}
