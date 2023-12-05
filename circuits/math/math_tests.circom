pragma circom 2.1.6;

include "./bitwise.circom";

template Test() {
  signal right_shift <== RightShift(8, 2)(105);
  log("105 >> 2", right_shift);

  signal left_shift <== LeftShift(8, 2)(105);
  log("105 << 2", left_shift);

  signal and <== And(8)(5, 3);
  log("5 & 3 = ", and);

  signal or <== Or(8)(5, 3);
  log("5 & 3 = ", or);
}

component main = Test();
