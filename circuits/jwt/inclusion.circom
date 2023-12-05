pragma circom 2.1.6;

include "../base64/encoder.circom";
include "../collections/slice.circom";
include "../utils/constants.circom";

template JwtInclusion(
  max_claim_size,
  max_encoded_claim_size,
  max_chunk_count,
  max_jwt_size
) {
  signal input jwt[max_jwt_size];
  signal input claim[max_claim_size];
  signal input claim_loc;
  
  // base64 encode the claim 
  component encoder = Encoder(max_claim_size, max_encoded_claim_size, max_chunk_count);
  encoder.value <== claim;

  signal isB64Char[max_jwt_size];
  signal within_jwt_slice[max_jwt_size];

  for(var i = 0; i < max_jwt_size; i++) {
    isB64Char[i] <== LessThan(8)(encoder.out[i], null_char());
    within_jwt_slice[i] <== GreaterEqThan(16)(i, claim_loc);

    // if both above values are 1 then we shoudl compare the corresponding jwt and encoded claim bytes
    
  }

  // component encode_claim_part = Slice(max_jwt_size);
  // encode_claim_part.arr <== jwt;
  // encode_claim_part.start <== claim_loc;
  // encode_claim_part.end <== claim_loc + encoder.out[max_encoded_claim_size];
}
