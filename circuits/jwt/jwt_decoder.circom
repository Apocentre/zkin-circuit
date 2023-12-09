pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../base64.circom";

template JwtDecoder(max_jwt_bytes, max_json_bytes) {
  signal input jwt[max_jwt_bytes];
  signal input header_len;
  
  signal output out[max_json_bytes];

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

  out <== jwt_ascii.out;
}
