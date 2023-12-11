pragma circom 2.1.6;

include "./crypto/rsa_sha256.circom";
include "./crypto/address.circom";
include "./jwt/claim_inclusion.circom";
include "./collections/utils.circom";

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
  signal input nonce[max_claim_bytes];
  signal input exp[max_claim_bytes];
  signal input iss_loc;
  signal input sub_loc;
  signal input aud_loc;
  signal input nonce_loc;
  signal input exp_loc;
  signal input salt[16];
  signal input modulus[k]; // jwt provider rsa pubkey
  signal input signature[k];

  signal output aud_out[max_claim_json_bytes];
  signal output nonce_out[max_claim_json_bytes];
  var max_timestamp_len = 10;
  signal output exp_out[max_timestamp_len];
  signal output address;

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
  nonce_out <== ClaimInclusion(max_claim_bytes, max_claim_json_bytes, jwt_chunk_size, chunk_count)(jwt_segments, nonce, nonce_loc);
  
  signal exp_ascii[max_claim_json_bytes] <== ClaimInclusion(
    max_claim_bytes, max_claim_json_bytes, jwt_chunk_size, chunk_count
  )(jwt_segments, exp, exp_loc);
  
  exp_out <== CopyArray(max_claim_json_bytes, max_timestamp_len)(exp_ascii);

  address <== Address(max_claim_json_bytes, k)(sub_ascii, iss_ascii, aud_out, salt);

  log("address ---> ", address);
}

// the max claim b64 len is 64 but the decoded one is  78 = (4/3)*(N + 2) => N = 104
component main {public [iss, iss_loc]} = ZkAuth(104, 78, 16, 64, 121, 17);
