pragma circom 2.1.6;

include "../base64/decoder.circom";
include "../collections/slice.circom";

template ClaimExtractor(
  max_claim_size,
  max_encoded_claim_size,
  max_chunk_count,
  jwt_segment_len
) {
  signal input jwt[jwt_segment_len];
  signal input value_loc;
  signal input value_len;
  signal output out[max_claim_size];

  // This slice will be base64 encoded.
  signal encoded_value[max_encoded_claim_size] <== SliceWithVariableLen(jwt_segment_len, max_encoded_claim_size, null_char())(
    jwt, value_loc, value_loc + value_len
  );
  
  component decoder = Decoder(max_claim_size, max_encoded_claim_size, max_chunk_count);
  decoder.value <== encoded_value;

  out <== decoder.out;
}
