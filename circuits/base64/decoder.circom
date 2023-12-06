pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../utils/not_equal.circom";
include "./lookup_table.circom";
include "../utils/constants.circom";
include "../math/aggregation.circom";
include "../math/bitwise.circom";

template ChunkSticher() {
  signal input chunk[5];
  // last item incudes the real len of the array
  signal output out[4];

  signal conds[4];
  conds[0] <== IsEqual()([chunk[3], 1]);
  conds[1] <== IsEqual()([chunk[3], 2]);
  conds[2] <== IsEqual()([chunk[3], 3]);
  conds[3] <== IsEqual()([chunk[3], 0]);
  var sum = conds[0] + conds[1] + conds[2];
}

template ChunkDecoder() {
  signal input chunk[5];
  signal output out[5];
  var chunk_len = chunk[4];

  signal b64_indexes[4];
  signal conds_1[4];
  signal c_1[4];
  var len = 0;

  for(var i = 0; i < 4; i++) {
    b64_indexes[i] <== GetIndexForChar()(chunk[i]);
    conds_1[i] <== LessThan(8)([i, chunk_len]);
    len += conds_1[i];

    /**
      if i < chunk_len {
        out[i] <== b64_indexes[i]
      } else {
        out[i] = null_char() 
      }
    */
    c_1[i] <== (1 - conds_1[i]) * null_char();
    out[i] <== conds_1[i] * b64_indexes[i] + c_1[i];
  }
}

template Decoder(max_size, max_encoded_size, max_chunk_count) {
  signal input value[max_encoded_size];
  signal output out[max_size];
  signal output len;

  signal chunks[max_chunk_count][5];
  signal has_value_conds[max_chunk_count][4];

  component stiches[max_chunk_count];
  component chunk_decoders[max_chunk_count];

  for(var i = 0; i < max_chunk_count; i++) {
    var start_index = i * 4;

    has_value_conds[i][0] <== LessThan(8)([value[start_index], null_char()]);
    has_value_conds[i][1] <== LessThan(8)([value[start_index + 1], null_char()]);
    has_value_conds[i][2] <== LessThan(8)([value[start_index + 2], null_char()]);
    has_value_conds[i][3] <== LessThan(8)([value[start_index + 3], null_char()]);
    var sum = has_value_conds[i][0] + has_value_conds[i][1] + has_value_conds[i][2] + has_value_conds[i][3];

    chunks[i] <== [value[start_index], value[start_index + 1], value[start_index + 2], value[start_index + 3], sum];

    chunk_decoders[i] = ChunkDecoder();
    chunk_decoders[i].chunk <== chunks[i];
  }
}

component main = Decoder(105, 140, 35);
