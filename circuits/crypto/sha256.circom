pragma circom 2.1.6;

include "@zk-email/circuits/helpers/sha.circom";
include "circomlib/circuits/bitify.circom";

/// Sha256 hashes the padded message
template Sha256(max_msg_bytes, n) {
  signal input message[max_msg_bytes];
  signal output out[];

  component sha = Sha256Bytes(max_msg_bytes);

  for (var i = 0; i < max_msg_bytes; i++) {
    sha.in_padded[i] <== message[i];
  }
  sha.in_len_padded_bytes <== message_padded_bytes;

  var msg_len = (256 + n) \ n;

  component base_msg[msg_len];
  for (var i = 0; i < msg_len; i++) {
    base_msg[i] = Bits2Num(n);
  }

  for (var i = 0; i < 256; i++) {
    base_msg[i \ n].in[i % n] <== sha.out[255 - i];
  }

  for (var i = 256; i < n * msg_len; i++) {
    base_msg[i \ n].in[i % n] <== 0;
  }
}
