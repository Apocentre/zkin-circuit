pragma circom 2.1.6;

include "../base64/decoder.circom";
include "../collections/utils.circom";

template JwtExtractor(
  max_claim_size,
  max_encoded_claim_size,
  max_chunk_count,
  max_jwt_size
) {
  signal input jwt[max_jwt_size];
  signal input value_loc;
  signal input value_len;
  signal output out[max_claim_size];

  // This slice will be base64 encoded.
  signal jwt_part[max_jwt_size] <== Slice(max_jwt_size, null_char())(jwt, value_loc, value_loc + value_len);
  signal encoded_value[max_encoded_claim_size] <== CopyArray(max_jwt_size, max_encoded_claim_size)(jwt_part);

  component decoder = Decoder(max_claim_size, max_encoded_claim_size, max_chunk_count);
  decoder.value <== encoded_value;

  out <== decoder.out;
}
