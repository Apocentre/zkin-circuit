pragma circom 2.1.6;

include "./jwt/inclusion.circom";
include "./jwt/extractor.circom";

template ZkAuth(
  max_claim_size,
  max_encoded_claim_size,
  max_chunk_count,
  max_jwt_size
) {
  signal input jwt[max_jwt_size];
  signal input iss[max_claim_size];
  signal input sub[max_claim_size];
  signal input iss_loc;
  signal input sub_loc;
  
  component iss_jwt_inclusion = JwtInclusion(
    max_claim_size,
    max_encoded_claim_size,
    max_chunk_count,
    max_jwt_size,
    1
  );

  iss_jwt_inclusion.jwt <== jwt;
  iss_jwt_inclusion.claim <== iss;
  iss_jwt_inclusion.claim_loc <== iss_loc;

  component sub_jwt_inclusion = JwtInclusion(
    max_claim_size,
    max_encoded_claim_size,
    max_chunk_count,
    max_jwt_size,
    1
  );

  sub_jwt_inclusion.jwt <== jwt;
  sub_jwt_inclusion.claim <== sub;
  sub_jwt_inclusion.claim_loc <== sub_loc;
}


// base64 encoded value has len = 4/3 * ascii_string_len
component main {public [iss, iss_loc]} = ZkAuth(102, 136, 34, 1000);
