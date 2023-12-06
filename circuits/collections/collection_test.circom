pragma circom 2.1.6;

include "./filter_zeros.circom";

template CollectionTest() {
  signal in[10] <== [1, 0, 0, 2, 3, 4, 0, 5, 0, 6];
  signal filter[10] <== FilterZeros(10)(in);

  for(var i = 0; i < 10; i++) {
    log(filter[i]);
  }
}

component main = CollectionTest();
