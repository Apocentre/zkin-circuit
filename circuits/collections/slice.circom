pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../math/aggregation.circom";

// Given an array of N elements return the value at `index`
template AtIndex(N) {
  signal input array[N];
  signal input index;
  signal output out;

  component sum = Sum(N);

  for (var i = 0; i < N; i++) {
    var isEqual = IsEqual()([i, index]);
    sum.in[i] <== isEqual * array[i];
  }

  out <== sum.out;
}

template Slice(N) {
  signal input arr[N];
  signal input start;
  signal input end;
  signal output out[N];

  // Require that start >= 0
  signal start_cond <== GreaterEqThan(10)([start, 0]);
  // start_cond.in <== [start, 0];
  start_cond === 1;

  // Require that end < N
  signal end_cond <== LessThan(10)([end, N]);
  end_cond === 1;

  // Select the elements at the indexes between start and end, and 0-pad the rest
  signal selections[N];
  signal rangeChecks[N];

  for(var i = 0; i < N; i++) {
    // Check that start + i < diff
    rangeChecks[i] <== LessThan(10)([start + i, end]);
    // Get the element at index: start + i
    selections[i] <== AtIndex(N)(arr, start + i);

    // Set 0 to indexes outside the range. If inside the set the value at index taken from selections[i]
    out[i] <== selections[i] * rangeChecks[i]; 
  }
}
