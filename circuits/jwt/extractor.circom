pragma circom 2.1.6;

include "../base64/decoder.circom";
include "../collections/utils.circom";

template JwtExtractor(
  max_claim_size,
  max_encoded_claim_size,
  max_chunk_count,
  max_jwt_size,
) {
  signal input jwt[max_jwt_size];
  signal input claim_loc;
  signal input claim_len;

  // This slice will be base64 encoded.
  signal jwt_part[max_jwt_size] <== Slice(max_jwt_size, null_char())(jwt, claim_loc, claim_loc + claim_len);
  signal encoded_value = CopyArray(max_jwt_size, max_encoded_claim_size)(jwt_part);
}
