pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";

// get and array of max_claim_json_bytes (e.g. 78) and splits it into 6 chunks of 13 bytes each
// Note these values are hardcoded and are based on the fact that max_claim_json_bytes = 78. If this values
// changes then we would need to adapt the hardcoded values too
template Chunk(max_claim_json_bytes) {
  signal input in[max_claim_json_bytes];
  signal output out[6][13];

  for(var i = 0; i < max_claim_json_bytes; i += 13) {
    var chunk = i / 13;
    for(var j = 0; j < 13; j++) {
      out[chunk][j] <== in[j + i];
    }
  }
}

template HashChunks() {
  signal input chunks[6][13];
  signal output out;

  component final_hash = Poseidon(6);

  for(var i = 0; i < 6; i++) {
    final_hash.inputs[i] <== Poseidon(13)(chunks[i]);
  }

  out <== final_hash.out;
}


/// It will compute `address = H(sub|iss|aud|salt)`
template Address(max_claim_json_bytes) {
  signal input sub[max_claim_json_bytes];
  signal input iss[max_claim_json_bytes];
  signal input aud[max_claim_json_bytes];
  signal input salt;

  signal output out;

  signal sub_hash <== HashChunks()(Chunk(max_claim_json_bytes)(sub));
  signal iss_hash <==  HashChunks()(Chunk(max_claim_json_bytes)(iss));
  signal aud_hash <==  HashChunks()(Chunk(max_claim_json_bytes)(aud));

  out <== Poseidon(4)([sub_hash, iss_hash, aud_hash, salt]);
}
