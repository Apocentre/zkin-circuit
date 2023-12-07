pragma circom 2.1.6;

include "../base64/decoder.circom";
include "../collections/utils.circom";

template HeaderExtractor(
  max_claim_size,
  max_encoded_claim_size,
  max_chunk_count,
  jwt_segment_len
) {
  // header will be in the first jwt sections
  signal input jwt[jwt_segment_len];
  signal input value_loc;
  signal input value_len;
  
  signal output out[max_claim_size];

  // This slice will be base64 encoded.
  signal jwt_part[jwt_segment_len] <== SliceFromStart(jwt_segment_len, jwt_segment_len)(jwt);
  signal encoded_value[max_encoded_claim_size] <== CopyArray(jwt_segment_len, max_encoded_claim_size)(jwt_part);

  component decoder = Decoder(max_claim_size, max_encoded_claim_size, max_chunk_count);
  decoder.value <== encoded_value;

  out <== decoder.out;
}
