pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";

template Address(max_claim_json_bytes) {
  signal input sub[max_claim_json_bytes];
  signal input iss[max_claim_json_bytes];
  signal input aud[max_claim_json_bytes];
  signal input salt[max_claim_json_bytes];

  signal output out;

  signal sub_hash <== Poseidon(max_claim_json_bytes)(sub);
  signal iss_hash <== Poseidon(max_claim_json_bytes)(iss);
  signal aud_hash <== Poseidon(max_claim_json_bytes)(aud);
  signal salt_hash <== Poseidon(max_claim_json_bytes)(salt);

  out <== Poseidon(4)([sub_hash, iss_hash, aud_hash, salt_hash]);
}
