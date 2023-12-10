pragma circom 2.1.6;

include "./jwt/claim_verifier.circom";
include "./jwt/jwt_slice.circom";
include "./crypto/rsa_sha256.circom";

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


  // 1. verify the signature
  // component rsa_sha256 = RsaSha256(chunk_count, jwt_chunk_size, n, k);
  // rsa_sha256.msg_padded_bytes <== jwt_padded_bytes;
  // rsa_sha256.msg_segments <== jwt_segments;
  // rsa_sha256.modulus <== modulus;
  // rsa_sha256.signature <== signature;

  // 2. prove iss inclusion
  signal iss_slice[jwt_chunk_size * 2];
  signal iss_first_segment;
  (iss_slice, iss_first_segment) <== JwtSlice(chunk_count, jwt_chunk_size)(jwt_segments, iss_loc, iss_loc + jwt_chunk_size);

  component iss_claim = ClaimVerifier(max_claim_bytes, max_claim_json_bytes, jwt_chunk_size * 2);
  iss_claim.jwt <== iss_slice;
  iss_claim.claim <== iss;
  iss_claim.claim_loc <== iss_loc - (iss_first_segment * jwt_chunk_size); // i.e. iss_loc % jwt_chunk_size
}


// the max claim b64 len is 64 but the decoded one is var  64 = (4/3)*(N + 2) => N = 88
component main {public [iss, iss_loc]} = ZkAuth(88, 64, 64, 16, 121, 17);
