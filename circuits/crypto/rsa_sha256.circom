pragma circom 2.1.6;

include "@zk-email/circuits/helpers/sha.circom";
include "circomlib/circuits/bitify.circom";
include "@zk-email/circuits/helpers/rsa.circom";

/// Sha256 hashes the padded message
template RsaSha256(max_msg_bytes, msg_chunk_size, n, k) {
  signal input msg_segments[8][msg_chunk_size];
  signal input msg_padded_bytes;
  signal input modulus[k];
  signal input signature[k];

  signal output out[n];

  signal message[max_msg_bytes];

  for(var i = 0; i < 8; i++) {
    for(var j = 0; j < msg_chunk_size; j++) {
      var index = i * msg_chunk_size + j;
      message[index] <== msg_segments[i][j];
    }
  }

  /// 1. Hash the provided message
  component sha = Sha256Bytes(max_msg_bytes);

  for (var i = 0; i < max_msg_bytes; i++) {
    sha.in_padded[i] <== message[i];
  }
  sha.in_len_padded_bytes <== msg_padded_bytes;

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

  /// 2 Verify the signature applies on the above hashed message
  component rsa = RSAVerify65537(n, k);
  for (var i = 0; i < msg_len; i++) {
    rsa.base_message[i] <== base_msg[i].out;
  }
  
  for (var i = msg_len; i < k; i++) {
    rsa.base_message[i] <== 0;
  }

  for (var i = 0; i < k; i++) {
    rsa.modulus[i] <== modulus[i];
  }
  
  for (var i = 0; i < k; i++) {
    rsa.signature[i] <== signature[i];
  }
}
