pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../utils/not_equal.circom";

template Encoder(max_size, max_encoded_siz, chunk_size) {
  signal input value[max_size];
  signal output out[max_encoded_siz];
  // index 4 will store the number of real value it has
  signal chunks[chunk_size][4];
  signal has_value_conditions[chunk_size][3];
  signal condition_eq[chunk_size][3];

  for(var i = 0; i < chunk_size; i++){
    var start_index = i * 3;

    /// Our arrays have a fixed size, but not all items are values that we need. For example, an fixed array might
    /// have a length of 100 items but we want to pass a byte array that has 30 values. The remianing 70 will be filled
    /// with a value that we know does not exist in ASCII not in base64 look up tables.
    has_value_conditions[i][0] <== NotEqual()([value[start_index], 256]);
    has_value_conditions[i][1] <== NotEqual()([value[start_index + 1], 256]);
    has_value_conditions[i][2] <== NotEqual()([value[start_index + 2], 256]);
    var sum = has_value_conditions[i][0] + has_value_conditions[i][1] + has_value_conditions[i][2];

    chunks[i] <== [value[start_index], value[start_index + 1], value[start_index + 2], sum];
  }
}

// base64 encoded value has len = 4/3 * ascii_string_len
component main  = Encoder(100, 134, 33);
