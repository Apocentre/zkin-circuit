const {writeFile} = require("fs/promises");
const assert = require("assert");
const data = require("./data.json");
const {findClaimLocation} = require("./claim_loc.js");
const {getClaimByteArray, padJwtHeader} = require("./jwt.js");
const {getPubkey} = require("./jwks.js");

// circom constants from main.circom / https://zkrepl.dev/?gist=30d21c7a7285b1b14f608325f172417b
// template RSAGroupSigVerify(n, k, levels) {
// component main { public [ modulus ] } = RSAVerify(121, 17);
// component main { public [ root, payload1 ] } = RSAGroupSigVerify(121, 17, 30);
const CIRCOM_BIGINT_N = 121;
const CIRCOM_BIGINT_K = 17;
const MAX_MSG_PADDED_BYTES = 1024;

const toCircomBigIntBytes = (num) => {
  const res = [];
  const bigintNum = typeof num == "bigint" ? num : num.valueOf();
  const msk = (1n << BigInt(CIRCOM_BIGINT_N)) - 1n;

  for (let i = 0; i < CIRCOM_BIGINT_K; ++i) {
    res.push(((bigintNum >> BigInt(i * CIRCOM_BIGINT_N)) & msk).toString());
  }
  
  return res;
}

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

const createInputs = async (msg=data.jwt, sig=data.sig) => {
  const signature = toCircomBigIntBytes(BigInt(`0x${Buffer.from(sig, "base64").toString("hex")}`));
  const jwtByteArray = new TextEncoder().encode(msg);
  const [jwtPadded, jwtPaddedLen] = await sha256Pad(jwtByteArray, MAX_MSG_PADDED_BYTES);
  const jwt_padded_bytes = jwtPaddedLen.toString();
  const jwt = await Uint8ArrayToCharArray(jwtPadded);
  const [dot_index, padCount, jwtWithHeaderPadding] = padJwtHeader(jwt);
  const iss_loc = findClaimLocation(msg, data.iss, padCount);
  const sub_loc = findClaimLocation(msg, data.sub, padCount);
  const aud_loc = findClaimLocation(msg, data.aud, padCount);  
  const rsaPubkey = toCircomBigIntBytes(await getPubkey(data.jwt));

  const inputs = {
    jwt: jwtWithHeaderPadding,
    jwt_padded_bytes,
    dot_index,
    iss: getClaimByteArray(data.iss),
    iss_loc,
    sub: getClaimByteArray(data.sub),
    sub_loc,
    aud_loc,
    aud_len: data.sub.length,
    signature,
    modulus: rsaPubkey,
  }

  await writeFile(
    `${__dirname}/../inputs/zk_auth.json`,
    JSON.stringify(inputs, null, 2),
  )
}

createInputs()
.then(() => {})
