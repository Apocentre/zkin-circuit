pragma circom 2.1.6;

include "./jwt/inclusion.circom";
include "./jwt/claim_extractor.circom";
include "./jwt/jwt_slice.circom";
include "./crypto/sha256.circom";
include "./math/integer_div.circom";

template ZkAuth(
  max_claim_size,
  max_encoded_claim_size,
  max_chunk_count,
  jwt_chunk_size,
  max_jwt_bytes, // essentially 8 * jwt_chunk_size
  n, k
) {
  /// We split jwt into 8 chunks of jwt_chunk_size
  signal input jwt_segments[8][jwt_chunk_size];
  signal input jwt_padded_bytes; // length of the jwt including the padding

  signal input iss[max_claim_size];
  signal input sub[max_claim_size];
  signal input iss_loc;
  signal input iss_padded;
  signal input sub_loc;
  signal input sub_padded;
  signal input aud_loc;
  signal input aud_len;
  signal input aud_offset;
  signal input modulus[k]; // jwt provider rsa pubkey
  signal input signature[k];

  // 1. Prove iss is included in the jwt token
  signal jwt_slice_iss[jwt_chunk_size * 2];
  signal iss_first_segment;
  (jwt_slice_iss, iss_first_segment) <== JwtSlice(jwt_chunk_size)(jwt_segments, iss_loc, iss_loc + jwt_chunk_size);
  
  component iss_jwt_inclusion = JwtInclusion(
    max_claim_size,
    max_encoded_claim_size,
    max_chunk_count,
    jwt_chunk_size * 2
  );

  iss_jwt_inclusion.jwt <== jwt_slice_iss;
  iss_jwt_inclusion.claim <== iss;
  iss_jwt_inclusion.has_padding <== iss_padded;
  // iss_loc refers to the location within the outer JWT but here we work we segments so we need to find
  // the index within the selected JwtSlice
  iss_jwt_inclusion.claim_loc <== iss_loc - (iss_first_segment * jwt_chunk_size); // i.e. iss_loc % jwt_chunk_size

  // 2. Prove sub is included in the jwt token
  signal sub_slice_iss[jwt_chunk_size * 2];
  signal sub_first_segment;
  (sub_slice_iss, sub_first_segment) <== JwtSlice(jwt_chunk_size)(jwt_segments, sub_loc, sub_loc + jwt_chunk_size);
  
  component sub_jwt_inclusion = JwtInclusion(
    max_claim_size,
    max_encoded_claim_size,
    max_chunk_count,
    jwt_chunk_size * 2
  );

  sub_jwt_inclusion.jwt <== sub_slice_iss;
  sub_jwt_inclusion.claim <== sub;
  sub_jwt_inclusion.has_padding <== sub_padded;
  sub_jwt_inclusion.claim_loc <== sub_loc - (sub_first_segment * jwt_chunk_size); // i.e. sub_loc % jwt_chunk_size

  // 3. Extract and decode just the aud part from the jwt token
  signal jwt_slice_aud[jwt_chunk_size * 2];
  signal aud_first_segment;
  (jwt_slice_aud, aud_first_segment) <== JwtSlice(jwt_chunk_size)(jwt_segments, aud_loc, aud_loc + aud_len);
  
  // Decoder uses slightly but predictably different max_lengths from the encoder. The reason is that encoder works
  // with chunks of 3 but decoder with chunks of 4 so we want max_lengths to be divisible by these numbers
  component aud_extractor = ClaimExtractor(
    max_claim_size,
    max_encoded_claim_size,
    max_chunk_count,
    jwt_chunk_size * 2
  );

  aud_extractor.jwt <== jwt_slice_aud;
  aud_extractor.value_loc <== aud_loc - (aud_first_segment * jwt_chunk_size); // i.e. nonc_loc % jwt_chunk_size;
  aud_extractor.value_len <== aud_len;

  // TODO: aud_extractor.out might have an offset i.e. we would need to remove either 1 or 2 values to
  // be able to use this value in later operations.

  // 4. verify the signature
  component sha256 = Sha256(max_jwt_bytes, jwt_chunk_size, n);
  sha256.msg_padded_bytes <== jwt_padded_bytes;
  sha256.msg_segments <== jwt_segments;
}


// base64 encoded value has len = 4/3 * ascii_string_len
component main {public [iss, iss_loc]} = ZkAuth(75, 100, 25, 128, 1024, 121, 17);
