pragma circom 2.1.6;


include "./crypto/rsa_sha256.circom";
include "./jwt/claim_inclusion.circom";

template ZkAuth(
  max_claim_bytes,
  max_claim_json_bytes,
  jwt_chunk_size,
  chunk_count,
  n, k
) {
  /// We split jwt into chunk_count chunks of jwt_chunk_size
  signal input jwt_segments[chunk_count][jwt_chunk_size];
  signal input jwt_padded_bytes; // length of the jwt including the padding

  signal input iss[max_claim_bytes];
  signal input sub[max_claim_bytes];
  signal input aud[max_claim_bytes];
  signal input iss_loc;
  signal input sub_loc;
  signal input aud_loc;
  signal input modulus[k]; // jwt provider rsa pubkey
  signal input signature[k];

  signal output aud_out[max_claim_json_bytes];

  // 1. verify the signature
  component rsa_sha256 = RsaSha256(chunk_count, jwt_chunk_size, n, k);
  rsa_sha256.msg_padded_bytes <== jwt_padded_bytes;
  rsa_sha256.msg_segments <== jwt_segments;
  rsa_sha256.modulus <== modulus;
  rsa_sha256.signature <== signature;

  // 2. prove claims inclusions
  signal iss_ascii[max_claim_json_bytes] <== ClaimInclusion(
    max_claim_bytes, max_claim_json_bytes, jwt_chunk_size, chunk_count
  )(jwt_segments, iss, iss_loc);
  signal sub_ascii[max_claim_json_bytes] <== ClaimInclusion(
    max_claim_bytes, max_claim_json_bytes, jwt_chunk_size, chunk_count
  )(jwt_segments, sub, sub_loc);
  
  aud_out <== ClaimInclusion(max_claim_bytes, max_claim_json_bytes, jwt_chunk_size, chunk_count)(jwt_segments, aud, aud_loc);
}

// the max claim b64 len is 64 but the decoded one is var  64 = (4/3)*(N + 2) => N = 88
component main {public [iss, iss_loc]} = ZkAuth(88, 64, 64, 16, 121, 17);
