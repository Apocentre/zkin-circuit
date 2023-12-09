pragma circom 2.1.6;

include "./crypto/rsa_sha256.circom";
include "./jwt/jwt_decoder.circom";
include "./math/integer_div.circom";

template ZkAuth(
  max_claim_size,
  jwt_chunk_size,
  max_jwt_bytes, // essentially 8 * jwt_chunk_size
  n, k
) {
  /// We split jwt into 8 chunks of jwt_chunk_size
  signal input jwt_segments[8][jwt_chunk_size];
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

  // 1. Join the jwt segments
  signal jwt[max_jwt_bytes];

  for(var i = 0; i < 8; i++) {
    for(var j = 0; j < jwt_chunk_size; j++) {
      var index = i * jwt_chunk_size + j;
      jwt[index] <== jwt_segments[i][j];
    }
  }

  // 1. Decode the jwt token
  var max_json_bytes = (max_jwt_bytes * 3) / 4;
  signal jwt_ascii[max_json_bytes] <== JwtDecoder(max_jwt_bytes, max_json_bytes)(jwt, header_len);

  // 4. verify the signature
  component rsa_sha256 = RsaSha256(max_jwt_bytes, n, k);
  rsa_sha256.message <== jwt;
  rsa_sha256.msg_padded_bytes <== jwt_padded_bytes;
  rsa_sha256.modulus <== modulus;
  rsa_sha256.signature <== signature;
}


// base64 encoded value has len = 4/3 * ascii_string_len
component main {public [iss, iss_loc]} = ZkAuth(75, 128, 1024, 121, 17);
