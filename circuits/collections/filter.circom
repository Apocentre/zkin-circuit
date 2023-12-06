pragma circom 2.1.6;

/// Filter all occurences of the given item from the input array. Fitlering essentially means moving all 
/// matches to the end of the output array.

template Filter(N) {
  signal input in[N];
  signal input match; 

  signal output out[N];
}
