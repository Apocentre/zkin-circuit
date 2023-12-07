pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../utils/not_equal.circom";
include "./lookup_table.circom";
include "../utils/constants.circom";
include "../collections/filter_zeros.circom";
include "../math/bitwise.circom";

template ChunkSticher() {
  signal input chunk[5];
  signal output out[3];

  // (chunk[0] & 63) << 2 | chunk[1] >> 4
  signal val_1_0 <== Or(8)(
    LeftShift(8, 2)(And(8)(chunk[0], 63)),
    RightShift(8, 4)(chunk[1])
  );
  // (chunk[1] & 15) << 4
  signal val_1_1 <== LeftShift(8, 4)(And(8)(chunk[1], 15));
  
  // (chunk[1] & 15) << 4 | chunk[2] >> 2)
  signal val_2_1 <== Or(8)(
    LeftShift(8, 4)(And(8)(chunk[1], 15)),
    RightShift(8, 2)(chunk[2])
  );
  // (chunk[2] & 3) << 6)
  signal val_2_2 <== LeftShift(8, 6)(And(8)(chunk[2], 3));
  // (chunk[2] & 3) << 6 | chunk[3] & 63)
  signal val_3_1 <== Or(8)(
    LeftShift(8, 6)(And(8)(chunk[2], 3)),
    And(8)(chunk[3], 63)
  );

  signal arr_1[3] <== [val_1_0, val_1_1, 0];
  signal arr_2[3] <== [val_1_0, val_2_1, val_2_2];
  signal arr_3[3] <== [val_1_0, val_2_1, val_3_1];

  signal conds[4];
  conds[0] <== IsEqual()([chunk[4], 2]);
  conds[1] <== IsEqual()([chunk[4], 3]);
  conds[2] <== IsEqual()([chunk[4], 4]);
  
  signal c_3[3];
  signal c_2[3];
  signal c_2_i[3];
  signal c_1[3];

  for(var i = 0; i < 3; i++) {
    /**
      if chunk_len == 2 {
        out[i] = arr_1[i];
      } else if chunk_len == 3 {
        out[i] = arr_2[i];
      } else if chunk_len == 4 {
        out[i] = arr_3[i];
      }
    **/
    c_3[i] <== conds[2] * arr_3[i];
    c_2[i] <== (1 - conds[1]) * c_3[i];
    c_2_i[i] <== conds[1] * arr_2[i] + c_2[i];
    c_1[i] <== (1 - conds[0]) * c_2_i[i];

    out[i] <== conds[0] * arr_1[i] + c_1[i];
  }
}

template ChunkDecoder() {
  signal input chunk[5];
  signal output out[5];
  var chunk_len = chunk[4];

  signal b64_indexes[4];
  signal conds[4];
  signal c_1[4];
  var len = 0;

  for(var i = 0; i < 4; i++) {
    b64_indexes[i] <== GetIndexForChar()(chunk[i]);
    conds[i] <== LessThan(8)([i, chunk_len]);
    len += conds[i];

    /**
      if i < chunk_len {
        out[i] <== b64_indexes[i]
      } else {
        out[i] = null_char() 
      }
    */
    c_1[i] <== (1 - conds[i]) * null_char();
    out[i] <== conds[i] * b64_indexes[i] + c_1[i];
  }

  out[4] <== len;
}

template Decoder(max_size, max_encoded_size, max_chunk_count) {
  signal input value[max_encoded_size];
  signal output out[max_size];
  signal output buffer[max_size];

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
    stiches[i] = ChunkSticher();
    stiches[i].chunk <== chunk_decoders[i].out;

    for(var j = 0; j < 3; j++) {
      var index = i * 3;
      var j_index = index + j;
      buffer[j_index] <== stiches[i].out[j];
    }
  }

  out <== FilterZeros(max_size)(buffer);
}

// component main = Decoder(105, 140, 35);
