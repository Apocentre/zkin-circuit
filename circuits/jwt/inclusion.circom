pragma circom 2.1.6;

include "../base64/encoder.circom";
include "../collections/slice.circom";

template JwtInclusion(
  max_claim_size,
  max_encoded_claim_size,
  max_chunk_count,
  max_jwt_size
) {
  signal input jwt[max_jwt_size];
  signal input claim[max_claim_size];
  signal input claim_loc;
  
  component encoder = Encoder(max_claim_size, max_encoded_claim_size, max_chunk_count);
  encoder.value <== claim;

  component encode_claim_part = Slice(max_jwt_size);
  encode_claim_part.arr <== jwt;
  encode_claim_part.start <== claim_loc;
  encode_claim_part.end <== claim_loc + encoder.out[max_encoded_claim_size];
}
