pragma circom 2.1.6;

include "../base64.circom";


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

  signal selections[max_encoded_claim_size];
  signal assertions[max_encoded_claim_size];

  // verify that the entier clzaim is inluded in the JWT
  for(var i = 0; i < max_claim_bytes; i++) {
    selections[i] <== AtIndex(jwt_segment_len)(jwt, claim_loc + i);

    // make sure all bytes are the same
    assertions[i] <== IsEqual()([claim[i] * selections[i], selections[i] * selections[i]]);
    assertions[i] === 1;
  }
  
  component claim_ascii = Base64Decode(max_claim_json_bytes);
}
