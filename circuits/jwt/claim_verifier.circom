pragma circom 2.1.6;

include "../base64.circom";
include "../collections/slice.circom";
include "../utils/not_equal.circom";
include "./claim_sanitizer.circom";


/// Accepts a b64 encoded subsection of jwt and claim and will:
/// 
/// 1. prove that the b64 encoded claim value is included in the given jwt
/// 2. decode the b64 encoded claim and return the ascii value
template ClaimVerifier(
  max_claim_bytes,
  max_claim_json_bytes,
  jwt_segment_len
) {
  signal input jwt[jwt_segment_len];
  signal input claim[max_claim_bytes];
  signal input claim_loc;
  signal output out[max_claim_json_bytes];

  signal selections[max_claim_bytes];
  signal assertions[max_claim_bytes];
  signal is_zero[max_claim_bytes];

  // 1. verify that the entier claim is inluded in the JWT
  for(var i = 0; i < max_claim_bytes; i++) {
    selections[i] <== AtIndex(jwt_segment_len)(jwt, claim_loc + i);
    is_zero[i] <== NotEqual()([claim[i], 0]);
    
    // make sure all bytes are the same
    assertions[i] <== IsEqual()([claim[i] * is_zero[i], selections[i] * is_zero[i]]);
    assertions[i] === 1;
  }
  
  // 2. Decode the b64 encoded claim value
  out <== Base64Decode(max_claim_json_bytes)(claim);
}
