pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../utils/not_equal.circom";
include "./lookup_table.circom";
include "./constants.circom";

template ChunkSplitter() {
  signal input chunk[4];
  // the splited chunk can have up to 4 bytes. The fifth item decides the length of the dynamic array
  signal output out[5];

  signal conds[3];
  conds[0] <== IsEqual()([chunk[3], 1]);
  conds[1] <== IsEqual()([chunk[3], 2]);
  conds[2] <== IsEqual()([chunk[3], 3]);
  var sum = conds[0] + conds[1] + conds[2];

  signal arr_1[5] <-- [chunk[0] >> 2, (chunk[0] & 3) << 4, 0, 0, 2];
  signal arr_2[5] <-- [chunk[0] >> 2, (chunk[0] & 3) << 4 | chunk[1] >> 4, (chunk[1] & 15) << 2, 0, 3];
  signal arr_3[5] <-- [
    chunk[0] >> 2,
    (chunk[0] & 3) << 4 | chunk[1] >> 4,
    (chunk[1] & 15) << 2 | chunk[2] >> 6,
    chunk[2] & 63,
    4
  ];

  signal c_3[5];
  signal c_2[5];
  signal c_2_i[5];
  signal c_1[5];

  for(var i = 0; i < 5; i++) {
    /**
      if chunk_len == 1 {
        out[i] = arr_1;
      } else if chunk_len == 2 {
        out[i] = arr_2;
      } else if chunk_len == 3 {
        out[i] = arr_2;
      }
    **/
    c_3[i] <== conds[2] * arr_3[i];
    c_2[i] <== conds[1] * arr_2[i] + (1 - conds[1]);
    c_2_i[i] <== c_2[i] * c_3[i];
    c_1[i] <== conds[0] * arr_1[i] + (1 - conds[0]);
    out[i] <== c_1[i] * c_2_i[i];
  }
}

template ChunkEncoder() {
  signal input chunk[5];
  signal output out[4];
  var chunk_len = chunk[4];

  signal conds[4];

  for(var i = 0; i < 4; i++) {
    conds[i] <== LessEqThan(8)([i, chunk_len]);
    /**
      if i <= chunk_len {
        out[i] <== chunk[i]
      } else {
        out[i] = get_padding_char() 
      }
    */
    out[i] <== conds[i] * chunk[i] + (1 - conds[i]) * get_padding_char();
  }
}


template Encoder(max_size, max_encoded_size, max_chunk_count) {
  signal input value[max_size];
  signal output out[max_encoded_size];
  // index 4 will store the number of real value it has
  signal chunks[max_chunk_count][4];
  signal has_value_conds[max_chunk_count][3];
  signal condition_eq[max_chunk_count][3];
  signal valid_sums[max_chunk_count];
  component splits[max_chunk_count];
  component chunk_encoders[max_chunk_count];
  var last_processed_index = 0;

  for(var i = 0; i < max_chunk_count; i++){
    var start_index = i * 3;

    /// Our arrays have a fixed size, but not all items are values that we need. For example, an fixed array might
    /// have a length of 100 items but we want to pass a byte array that has 30 values. The remaining 70 will be filled
    /// with a value that we know does not exist in ASCII not in base64 look up tables.
    /// So we want to work only on valid bytes i.e. byte != 256 and ingore the rest
    has_value_conds[i][0] <== NotEqual()([value[start_index], null_char()]);
    has_value_conds[i][1] <== NotEqual()([value[start_index + 1], null_char()]);
    has_value_conds[i][2] <== NotEqual()([value[start_index + 2], null_char()]);
    var sum = has_value_conds[i][0] + has_value_conds[i][1] + has_value_conds[i][2];

    // sum will help other parts of the code to know how many items this chunk does have indeed. We do 
    // insert a full chunk of 3 items, but some of those might not have any value i.e. they store the placeholder 256
    chunks[i] <== [value[start_index], value[start_index + 1], value[start_index + 2], sum];

    splits[i] = ChunkSplitter();
    splits[i].chunk <== chunks[i];
    chunk_encoders[i] = ChunkEncoder();
    chunk_encoders[i].chunk <== splits[i].out;

    for(var j = 0; j < 4; j++) {
      var index = i * 4;
      out[index + j] <== chunk_encoders[i].out[j];
    }
  }
}

// base64 encoded value has len = 4/3 * ascii_string_len
// the third param is the max chunk count for a string of max_size of 100 bytes Floor(100 / 3) = 3
component main = Encoder(100, 134, 33);
