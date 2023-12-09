pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../base64.circom";

template JwtDecoder(max_jwt_bytes, max_json_bytes, jwt_ascii_chunk_size) {
  signal input jwt[max_jwt_bytes];
  signal input header_len;
  
  var chunk_count = (max_json_bytes + 2) / jwt_ascii_chunk_size;
  signal output out[chunk_count][jwt_ascii_chunk_size];

  component jwt_ascii = Base64Decode(max_json_bytes);
  signal eqs[max_jwt_bytes];
  signal normal_bytes[max_jwt_bytes];

  // we have to ignore the "." between then header and the payload.
  for (var i = 0; i < max_jwt_bytes - 1; i++) {
    // is dot?
    eqs[i] <== GreaterEqThan(15)([i, header_len]);
    
    normal_bytes[i] <== (1 - eqs[i]) * jwt[i];
    jwt_ascii.in[i] <== eqs[i] * jwt[i + 1] + normal_bytes[i];
  }

  jwt_ascii.in[max_jwt_bytes - 1] <== 0;

  // 1. copy the decode result into an array which is has 2 more elements padded with 0
  signal buffer[max_json_bytes + 2];
  for(var i = 0; i < max_json_bytes; i++) {
    buffer[i] <== jwt_ascii.out[i];
  }

  // 2. pad last 2 items with 0
  buffer[max_json_bytes] <== 0;
  buffer[max_json_bytes + 1] <== 0;

  // 3. split into an array of `chunk_count` chunks of size jwt_ascii_chunk_size each
  for(var i = 0; i < max_json_bytes + 2; i += jwt_ascii_chunk_size) {
    var chunk_index = i / jwt_ascii_chunk_size;

    for(var j = 0; j < jwt_ascii_chunk_size; j++) {
      out[chunk_index][j] <== buffer[i + j];
    }
  }
}
