pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";
include "../utils/constants.circom";
include "./jwt_slice.circom";
include "../collections/slice.circom";

template JwtInclusion(max_claim_size, chunk_count, jwt_ascii_chunk_size) {
  signal input jwt_ascii[chunk_count][jwt_ascii_chunk_size];
  signal input claim[max_claim_size];
  signal input claim_loc;

  var jwt_segment_len = jwt_ascii_chunk_size * 2;

  // get two consequative segments fro, the jwt_ascii. Out claim can span at most two segements/
  // This way we reduce the search space when doing the byte comparison below.
  signal jwt_slice[jwt_segment_len];
  signal first_segment;

  (jwt_slice, first_segment) <== JwtSlice(chunk_count, jwt_ascii_chunk_size)(
    jwt_ascii, claim_loc, claim_loc + jwt_ascii_chunk_size
  );

  // claim_loc refers to the location within the outer JWT but here we work we segments so we need to find
  // the index within the selected JwtSlice
  signal final_claim_loc <== claim_loc - (first_segment * jwt_ascii_chunk_size); // claim_loc % jwt_ascii_chunk_size

  signal selections[max_claim_size];
  signal assertions[max_claim_size];

  for(var i = 0; i < max_claim_size; i++) {
    selections[i] <== AtIndex(jwt_segment_len)(jwt_slice, final_claim_loc + i);
    // make sure all bytes are the same
    assertions[i] <== IsEqual()([claim[i], selections[i]]);
    assertions[i] === 1;
  }
}
