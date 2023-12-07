pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../math/integer_div.circom";

template SegmentSearch(jwt_chunk_size) {
  signal input segment_index;
  signal input jwt_0[jwt_chunk_size];
  signal input jwt_1[jwt_chunk_size];
  signal input jwt_2[jwt_chunk_size];
  signal input jwt_3[jwt_chunk_size];
  signal input jwt_4[jwt_chunk_size];
  signal input jwt_5[jwt_chunk_size];
  signal input jwt_6[jwt_chunk_size];
  signal input jwt_7[jwt_chunk_size];
  signal input jwt_8[jwt_chunk_size];
  signal input jwt_9[jwt_chunk_size];
  signal output out[jwt_chunk_size];

  /// find first segment
  signal seg_0_eq <== IsEqual()([segment_index, 0]);
  signal seg_1_eq <== IsEqual()([segment_index, 1]);
  signal seg_2_eq <== IsEqual()([segment_index, 2]);
  signal seg_3_eq <== IsEqual()([segment_index, 3]);
  signal seg_4_eq <== IsEqual()([segment_index, 4]);
  signal seg_5_eq <== IsEqual()([segment_index, 5]);
  signal seg_6_eq <== IsEqual()([segment_index, 6]);
  signal seg_7_eq <== IsEqual()([segment_index, 7]);
  signal seg_8_eq <== IsEqual()([segment_index, 8]);
  signal seg_9_eq <== IsEqual()([segment_index, 9]);
  signal seg_10_eq <== IsEqual()([segment_index, 10]);

  signal c_9[jwt_chunk_size]; signal c_9_i[jwt_chunk_size];
  signal c_8[jwt_chunk_size]; signal c_8_i[jwt_chunk_size];
  signal c_7[jwt_chunk_size]; signal c_7_i[jwt_chunk_size];
  signal c_6[jwt_chunk_size]; signal c_6_i[jwt_chunk_size];
  signal c_5[jwt_chunk_size]; signal c_5_i[jwt_chunk_size];
  signal c_4[jwt_chunk_size]; signal c_4_i[jwt_chunk_size];
  signal c_3[jwt_chunk_size]; signal c_3_i[jwt_chunk_size];
  signal c_2[jwt_chunk_size]; signal c_2_i[jwt_chunk_size];
  signal c_1[jwt_chunk_size]; signal c_1_i[jwt_chunk_size];
  signal c_0[jwt_chunk_size]; signal c_0_i[jwt_chunk_size];

  for(var i = 0; i < jwt_chunk_size; i++) {
    /*
      if(segment_index == 1) {
        out <== jwt_0
      } else if(segment_index == 2) {
        ....
      }
    **/
    c_9[i] <== seg_9_eq * jwt_9[i];
    c_8_i[i] <== (1 - seg_8_eq) * c_9[i];
    c_8[i] <== seg_8_eq * jwt_8[i] + c_8_i[i];
    c_7_i[i] <== (1 - seg_7_eq) * c_8[i];
    c_7[i] <== seg_7_eq * jwt_7[i] + c_7_i[i];
    c_6_i[i] <== (1 - seg_6_eq) * c_7[i];
    c_6[i] <== seg_6_eq * jwt_6[i] + c_6_i[i];
    c_5_i[i] <== (1 - seg_5_eq) * c_6[i];
    c_5[i] <== seg_5_eq * jwt_5[i] + c_5_i[i];
    c_4_i[i] <== (1 - seg_4_eq) * c_5[i];
    c_4[i] <== seg_4_eq * jwt_4[i] + c_4_i[i];
    c_3_i[i] <== (1 - seg_3_eq) * c_4[i];
    c_3[i] <== seg_3_eq * jwt_3[i] + c_3_i[i];
    c_2_i[i] <== (1 - seg_2_eq) * c_3[i];
    c_2[i] <== seg_2_eq * jwt_2[i] + c_2_i[i];
    c_1_i[i] <== (1 - seg_1_eq) * c_2[i];
    c_1[i] <== seg_1_eq * jwt_1[i] + c_1_i[i];
    c_0_i[i] <== (1 - seg_0_eq) * c_1[i];
    c_0[i] <== seg_0_eq * jwt_0[i] + c_0_i[i];
    
    out[i] <== c_1[i];
  }
}

/// For optimization reasons we split the jwt into 10 smaller parts each having one segment of. These
/// parts are in the order as the bytes appear in the origin JWT byte array.
/// This circuit will accept all jwt segments, as well as, the start index and end index that correspons to the
/// original single JWT byte array. It will then decide which two segments to merge into one. Our circuits works with
/// base64 encoded values of max length `jwt_chunk_size` which most likely be 100. So we know that the encoded value
/// will at most span across 2 of the below segments.
template JwtSlice(jwt_chunk_size) {
  signal input jwt_0[jwt_chunk_size];
  signal input jwt_1[jwt_chunk_size];
  signal input jwt_2[jwt_chunk_size];
  signal input jwt_3[jwt_chunk_size];
  signal input jwt_4[jwt_chunk_size];
  signal input jwt_5[jwt_chunk_size];
  signal input jwt_6[jwt_chunk_size];
  signal input jwt_7[jwt_chunk_size];
  signal input jwt_8[jwt_chunk_size];
  signal input jwt_9[jwt_chunk_size];
  signal input start;
  signal input end;

  signal output out[jwt_chunk_size * 2];
  signal output first_segment_index;

  first_segment_index <== IntegerDivision(10)(start, jwt_chunk_size);
  signal end_segment_index <== IntegerDivision(10)(end, jwt_chunk_size);

  /// Find the two segments
  signal segment_1[jwt_chunk_size] <== SegmentSearch(jwt_chunk_size)(
    first_segment_index, jwt_0, jwt_1, jwt_2, jwt_3, jwt_4, jwt_5, jwt_6, jwt_7, jwt_8, jwt_9
  );
  signal segment_2[jwt_chunk_size] <== SegmentSearch(jwt_chunk_size)(
    end_segment_index, jwt_0, jwt_1, jwt_2, jwt_3, jwt_4, jwt_5, jwt_6, jwt_7, jwt_8, jwt_9
  );

  // Note that the two segments might be the same a thus the concated output will essentially have the same slice twice
  // Our output has to have jwt_chunk_size * 2 lenth since we can have values that might span two such segments. And since
  // the final length must be a fixed value we have to copy the same values twice if start_index_segment == end_index_segment
  for(var i = 0; i < jwt_chunk_size; i++) {
    out[i] <== segment_1[i];
    out[i + jwt_chunk_size] <== segment_2[i];
  }
}
