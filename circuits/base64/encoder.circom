pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../utils/not_equal.circom";

template Encoder(max_size, max_encoded_siz, chunk_size) {
  signal input value[max_size];
  signal output out[max_encoded_siz];
  signal chunks[chunk_size][3];
  signal has_value_conditions[chunk_size][3];

  for(var i = 0; i < chunk_size; i++){
    var chunk_size_1;
    var chunk_size_2;
    var chunk_size_3;

    var start_index = i * 3;
    chunk_size_1 = value[start_index];
    chunk_size_2 = value[start_index];
    chunk_size_2 = value[start_index + 1];
    chunk_size_3 = value[start_index];
    chunk_size_3 = value[start_index + 1];
    chunk_size_3 = value[start_index + 2];

    /// Our arrays have a fixed size, but not all items are values that we need. For example, an fixed array might
    /// have a length of 100 items but we want to pass a byte array that has 30 values. The remianing 70 will be filled
    /// with a value that we know does not exist in ASCII not in base64 look up tables.
    has_value_conditions[i][0] <== NotEqual()([value[start_index], 256]);
    has_value_conditions[i][1] <== NotEqual()([value[start_index + 1], 256]);
    has_value_conditions[i][2] <== NotEqual()([value[start_index + 2], 256]);

    // not check decide which chunk_size array we will pick based on the has_value_conditions

  }
}

// base64 encoded value has len = 4/3 * ascii_string_len
component main  = Encoder(100, 134, 33);
