pragma circom 2.1.6;

include "./filter.circom";

template CollectionTest() {
  signal in[10] = [1, 0, 0, 2, 3, 4, 0, 5, 0, 1]
  signal filter = FilterZeros(10)(in, );
}

component main = CollectionTest();
