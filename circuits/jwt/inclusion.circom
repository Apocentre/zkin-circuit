pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";
include "../base64/encoder.circom";
include "../utils/constants.circom";
include "../collections/slice.circom";
include "../utils/range.circom";

template JwtInclusion(
  max_claim_size,
  max_encoded_claim_size,
  max_chunk_count,
  jwt_segment_len
) {
  signal input jwt[jwt_segment_len];
  signal input claim[max_claim_size];
  signal input claim_loc;
  signal input has_padding;
  
  // base64 encode the claim 
  component encoder = Encoder(max_claim_size, max_encoded_claim_size, max_chunk_count);
  encoder.value <== claim;

  // remove first 4 and last 4 bytes if encoded claim is padded i.e. offset 1 or 2 
  signal start <== has_padding * 4;
  signal end <== encoder.len - start;
  signal final_encoded_claim[max_encoded_claim_size] <== Slice(max_encoded_claim_size, null_char())(encoder.out, start, end);

  signal isB64Char[jwt_segment_len];
  signal selections[max_encoded_claim_size];
  signal assertions[max_encoded_claim_size];

  for(var i = 0; i < max_encoded_claim_size; i++) {
    selections[i] <== AtIndex(jwt_segment_len)(jwt, claim_loc + i);

    // make sure all bytes are the same
    isB64Char[i] <== LessThan(8)([final_encoded_claim[i], null_char()]);
    assertions[i] <== IsEqual()([isB64Char[i] * final_encoded_claim[i], selections[i] * isB64Char[i]]);

    assertions[i] === 1;
  }
}
