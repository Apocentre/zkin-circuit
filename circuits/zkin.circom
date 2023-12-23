pragma circom 2.1.6;

include "./crypto/rsa_sha256.circom";
include "./crypto/address.circom";
include "./crypto/modulus.circom";
include "./jwt/claim_inclusion.circom";
include "./collections/utils.circom";

/// The circuit will verify a provided JWT.
///
/// # Input
///
/// * `jwt_segments` - The JWT bytes split into several chunks of the same size. We do this for performance reasons. This
/// way we reduce the number of contraints when it comes to do inclusion checks and in general searching in smaller chunks
/// is cheaper.
/// * `jwt_padded_bytes` - This is used in the RSA SHA256 template. It's the number of bytes of the jwt that will be verified
/// * `iss` (public) - This is the base64 encoded value of the `iss` claim within JWT
/// * `sub` - This is the base64 encoded value of the `sub` claim within JWT
/// * `aud` - This is the base64 encoded value of the `aud` claim within JWT
/// * `nonce` - This is the base64 encoded value of the `nonce` claim within JWT
/// * `exp` - This is the base64 encoded value of the `exp` claim within JWT
/// * `iss_loc` - The offset of the encoded `iss` value within the JWT token. Used to verify that value exist in JWT.
/// * `sub_loc` - The offset of the encoded `sub` value within the JWT token. Used to verify that value exist in JWT.
/// * `aud_loc` - The offset of the encoded `aud` value within the JWT token. Used to verify that value exist in JWT.
/// * `nonce_loc` - The offset of the encoded `nonce` value within the JWT token. Used to verify that value exist in JWT.
/// * `exp_loc` - The offset of the encoded `exp_loc` value within the JWT token. Used to verify that value exist in JWT.
/// * `salt` - The random salt value provided by the user. This is used in the address generation process.
/// * `modulus` - The public key of the provider that signed the JWT token e.g. google. This is a Circom compatible
/// big int bytes. 
/// * `signature` - The signaute of the header and payload parts of the JWT token. This is a Circom compatible
/// big int bytes. 
///
/// # Output
/// 
/// * `aud_out` - The decoded value of the `aud` claim provided in the input.
/// * `nonce_out` - The decoded value of the `nonce` claim provided in the input.
/// * `exp_out` - The decoded value of the `exp` claim provided in the input.
/// * `address` - The computed ZkInAddress
/// * `modulus_out` - The Poseidon hash value of the provided modulus input signal. This is used by the verifier
/// to make sure that the JWT token was indeed signed by a valid provider.
///
/// This circuit will run the following high level contraints:
///
/// 1. Verify that the signature was signed (via RSA) by a private key whose pub key is the given modulus
/// 2. Verify that the encoded `iss` is included in the JWT token and if so decode it.
/// 3. Verify that the encoded `sub` is included in the JWT token and if so decode it.
/// 4. Verify that the encoded `aud` is included in the JWT token and if so decode it.
/// 5. Verify that the encoded `nonce` is included in the JWT token and if so decode it.
/// 6. Verify that the encoded `exp included in the JWT token and if so decode it.
/// 7. Calculate the ZkInAddress
/// 7. Find the hash of input modulus
template ZkIn(
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
  signal output modulus_out;

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
  modulus_out <== Modulus()(modulus);
}

// the max claim b64 len is 64 but the decoded one is  78 = (4/3)*(N + 2) => N = 104
component main {public [iss]} = ZkIn(104, 78, 16, 64, 121, 17);
