pragma circom 2.1.6;

include "./crypto/rsa_sha256.circom";
include "./jwt/jwt_decoder.circom";
include "./jwt/inclusion.circom";
include "./math/integer_div.circom";

template ZkAuth(
  max_claim_size,
  max_jwt_bytes,
  max_json_bytes,
  jwt_ascii_chunk_size,
  n, k
) {
  signal input jwt[max_jwt_bytes];
  signal input jwt_padded_bytes; // length of the jwt including the padding

  signal input header_len;
  signal input iss[max_claim_size];
  signal input sub[max_claim_size];
  signal input iss_loc;
  signal input sub_loc;
  signal input aud_loc;
  signal input aud_len;
  signal input modulus[k]; // jwt provider rsa pubkey
  signal input signature[k];

  // 1. Decode the entire jwt token
  var chunk_count = (max_json_bytes + 2) / jwt_ascii_chunk_size;
  signal jwt_ascii[chunk_count][jwt_ascii_chunk_size] <== JwtDecoder(
    max_jwt_bytes, max_json_bytes, jwt_ascii_chunk_size
  )(jwt, header_len);


  // 3. Verify iss is located in the decoded jwt_ascii
  component iss_jwt_inclusion = JwtInclusion(max_claim_size, chunk_count, jwt_ascii_chunk_size);
  iss_jwt_inclusion.jwt_ascii <== jwt_ascii;
  iss_jwt_inclusion.claim <== iss;
  iss_jwt_inclusion.claim_loc <== iss_loc;

  // 4. verify the signature
  component rsa_sha256 = RsaSha256(max_jwt_bytes, n, k);
  rsa_sha256.message <== jwt;
  rsa_sha256.msg_padded_bytes <== jwt_padded_bytes;
  rsa_sha256.modulus <== modulus;
  rsa_sha256.signature <== signature;
}


// the max b64 len is 1024 but the decoded one is var  1024 = (4/3)*(N + 2) => N = 766
// jwt_ascii_chunk_size is the number of bytes that the decoded jwt will be grouped into
component main {public [iss, iss_loc]} = ZkAuth(64, 1024, 766, 64, 121, 17);
