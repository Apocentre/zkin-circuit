const {mkdir, readdir, copyFile, readFile, writeFile} = require("fs/promises");
const assert = require("assert");
const data = require("./data.json");
const findClaimLocation = require("./claim_loc");
const splitJWT = require("./split_jwt");

const MAX_MSG_PADDED_BYTES = 1024;

const mergeUInt8Arrays = (a1, a2) => {
  var mergedArray = new Uint8Array(a1.length + a2.length);
  mergedArray.set(a1);
  mergedArray.set(a2, a1.length);
  
  return mergedArray;
}

const int8toBytes = (num) => {
  const arr = new ArrayBuffer(1);
  const view = new DataView(arr);
  view.setUint8(0, num);

  return new Uint8Array(arr);
}

const int32toBytes = (num) => {
  const arr = new ArrayBuffer(4);
  const view = new DataView(arr);
  view.setUint32(0, num, false);

  return new Uint8Array(arr);
}

const Uint8ArrayToCharArray = (a) => {
  return Array.from(a).map((x) => x.toString());
}

// Puts an end selector, a bunch of 0s, then the length, then fill the rest with 0s.
const sha256Pad = async (prehash_prepad_m, maxShaBytes) => {
  const length_bits = prehash_prepad_m.length * 8; // bytes to bits
  const length_in_bytes = int32toBytes(length_bits);
  prehash_prepad_m = mergeUInt8Arrays(prehash_prepad_m, int8toBytes(2 ** 7));

  while ((prehash_prepad_m.length * 8 + length_in_bytes.length * 8) % 512 !== 0) {
    prehash_prepad_m = mergeUInt8Arrays(prehash_prepad_m, int8toBytes(0));
  }
  prehash_prepad_m = mergeUInt8Arrays(prehash_prepad_m, length_in_bytes);
  
  assert(
    (prehash_prepad_m.length * 8) % 512 === 0,
    "Padding did not compconste properly!"
  );

  const messageLen = prehash_prepad_m.length;
  while (prehash_prepad_m.length < maxShaBytes) {
    prehash_prepad_m = mergeUInt8Arrays(prehash_prepad_m, int32toBytes(0));
  }

  assert(
    prehash_prepad_m.length === maxShaBytes,
    "Padding to max length did not compconste properly!"
  );

  return [prehash_prepad_m, messageLen];
}

const createInputs = async (msg=data.jwt, signature=data.sig) => {
  const sig = BigInt(`0x${Buffer.from(signature, "base64").toString("hex")}`);
  
  const [messagePadded, messagePaddedLen] = await sha256Pad(new TextEncoder().encode(msg), MAX_MSG_PADDED_BYTES);
  const message_padded_bytes = messagePaddedLen.toString();
  const message = await Uint8ArrayToCharArray(messagePadded); 

  const issClaim = findClaimLocation(data.jwt, data.iss);
  const subClaim = findClaimLocation(data.jwt, data.sub);
  const audClaim = findClaimLocation(data.jwt, data.aud);
  
  const inputs = {
    jwt_segments: splitJWT(message),
    iss: issClaim[0],
    iss_loc: issClaim[1],
    iss_padded: issClaim[2],
    sub: subClaim[0],
    sub_loc: subClaim[1],
    sub_padded: subClaim[2],
    aud_loc: audClaim[1],
    aud_len: audClaim[0].length,
    aud_offset: audClaim[3],
  }

  await writeFile(
    `${__dirname}/../inputs/zk_auth.json`,
    JSON.stringify(inputs, null, 2),
  )
}

createInputs()
.then(() => {})
