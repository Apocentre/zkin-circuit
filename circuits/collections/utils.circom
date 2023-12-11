pragma circom 2.1.6;

// Simply copies the firs final_array_len elements from the big array into the smaller array
template CopyArray(big_array_len, final_array_len) {
  signal input big_array[big_array_len];
  signal output out[final_array_len];

  for(var i = 0; i < final_array_len; i++) {
    out[i] <== big_array[i];
  }
}
