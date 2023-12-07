pragma circom 2.1.6;

include "./jwt/inclusion.circom";
include "./jwt/extractor.circom";
include "./jwt/jwt_slice.circom";
include "./math/integer_div.circom";

template ZkAuth(
  max_claim_size,
  max_encoded_claim_size,
  max_chunk_count,
  jwt_chunk_size
) {
  /// We split jwt into 10 chunks of jwt_chunk_size
  signal input jwt_0[jwt_chunk_size];
  signal input jwt_1[jwt_chunk_size];
  signal input jwt_2[jwt_chunk_size];
  signal input jwt_3[jwt_chunk_size];
  signal input jwt_4[jwt_chunk_size];
  signal input jwt_5[jwt_chunk_size];
  signal input jwt_6[jwt_chunk_size];
  signal input jwt_7[jwt_chunk_size];
  signal input jwt_8[jwt_chunk_size];
  signal input jwt_9[jwt_chunk_size];

  signal input iss[max_claim_size];
  signal input sub[max_claim_size];
  signal input iss_loc;
  signal input sub_loc;
  signal input nonce_loc;
  signal input nonce_len;

  signal jwt_slice_iss[jwt_chunk_size * 2];
  signal first_segment;
  (jwt_slice_iss, first_segment) <== JwtSlice(jwt_chunk_size)(
    jwt_0, jwt_1, jwt_2, jwt_3, jwt_4, jwt_5, jwt_6, jwt_7, jwt_8, jwt_9, iss_loc, iss_loc + jwt_chunk_size
  );
  
  component iss_jwt_inclusion = JwtInclusion(
    max_claim_size,
    max_encoded_claim_size,
    max_chunk_count,
    jwt_chunk_size * 2,
    1
  );

  iss_jwt_inclusion.jwt <== jwt_slice_iss;
  iss_jwt_inclusion.claim <== iss;
  // iss_loc refers to the location within the outer JWT but here we work we segments so we need to find
  // the index within the selected JwtSlice
  // var segment = iss_loc / jwt_chunk_size;
  iss_jwt_inclusion.claim_loc <== iss_loc - (first_segment * jwt_chunk_size); // i.e. iss_loc % jwt_chunk_size

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

  // // Decoder uses slightly but predictably different max_lengths from the encoder. The reason is that encoder works
  // // with chunks of 3 but decoder with chunks of 4 so we want max_lengths to be divisible by these numbers
  // component nonce_extractor = JwtExtractor(
  //   max_claim_size + 3,
  //   max_encoded_claim_size + 4,
  //   max_chunk_count + 1,
  //   max_jwt_size
  // );

  // nonce_extractor.jwt <== jwt;
  // nonce_extractor.value_loc <== nonce_loc;
  // nonce_extractor.value_len <== nonce_len;
  // TODO: nonce_extractor.out might have an offset i.e. we would need to remove either 1 or 2 values to
  // be able to use this value in later operations.
}


// base64 encoded value has len = 4/3 * ascii_string_len
component main {public [iss, iss_loc]} = ZkAuth(75, 100, 25, 100);
