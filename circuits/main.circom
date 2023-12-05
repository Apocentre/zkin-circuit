pragma circom 2.1.6;

include "../jwt/inclusion.circom";

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
  
  component jwt_inclusion = JwtInclusion(
    max_claim_size,
    max_encoded_claim_size,
    max_chunk_count,
    max_jwt_size
  );

  max_jwt_size.jwt <== jwt;
  max_jwt_size.claim <== iss;
  max_jwt_size.claim_loc <== iss_loc;
}


// base64 encoded value has len = 4/3 * ascii_string_len
// the third param is the max chunk count for a string of max_size of 100 bytes Floor(100 / 3) = 3
component main = ZkAuth {public [iss, iss_loc]} (100, 134, 33, 1000);
