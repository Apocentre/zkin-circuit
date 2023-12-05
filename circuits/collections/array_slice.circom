pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/comparators.circom";

// The component will get a array of N elements where all elements will be 0 except for one.
// It will then run a Sum over all elements, essentially returning the value of that non-zero element.
template CalculateTotal(N) {
  signal input in[N];
  signal output out;

  signal outs[N];
  outs[0] <== in[0];

  for (var i=1; i < N; i++) {
    outs[i] <== outs[i - 1] + in[i];
  }

  out <== outs[N - 1];
}

// Given an array of N elements return the value at `index`
template AtIndex(N) {
  signal input array[N];
  signal input index;
  signal output out;

  component result = CalculateTotal(N);

  for (var i = 0; i < N; i++) {
    var isEqual = IsEqual()([i, index]);
    result.in[i] <== isEqual * array[i];
  }

  out <== result.out;
}

template Slice(N) {
  signal input arr[N];
  signal input start;
  signal input end;
  signal output out[N];

  // Require that start >= 0
  GreaterEqThan(10)([start, 0]) === 1;
  // Require that end < N
  LessThan(10)([end, N]) === 1;

  // Select the elements at the indexes between start and end, and 0-pad the rest
  signal selections[N];
  signal rangeChecks[N];

   for(var i = 0; i < N; i++) {
    // Check that start + i < diff
    rangeChecks = LessThan(10)([start + i, end])
    // Get the element at index: start + i
    selections[i] = AtIndex(N)([arr, start + i]);

    // Set 0 to indexes outside the range. If inside the set the value at index taken from selections[i]
    out[i] <== selections[i] * rangeChecks[i]; 
   }
}
