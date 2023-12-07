pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";

template Sha256Test() {
  /// We split jwt into 10 chunks of jwt_chunk_size
  signal input jwt_segments[10][100];
  signal bit_array[8000];
  component bits[1000];

  for(var i = 0; i < 10; i++) {
    for(var j = 0; j < 100; j++) {
      var index = i * 100 + j;

      bits[index] = Num2Bits(8);
      bits[index].in <== jwt_segments[i][j];

      for(var z = 0; z < 8; z++) {
        var index_2 = index * 8 + z;

        bit_array[index_2] <== bits[index].out[z];
      }
    }
  }

  signal out[256] <== Sha256(8000)(bit_array);

  for(var i = 0; i < 256; i++) {
    log(out[i]);
  }
}

component main = Sha256Test();
