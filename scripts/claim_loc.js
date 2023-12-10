const assert = require("assert");
const {
  COMMA_ASCII, COLON_ASCII, QUOTE_ASCII,
} = require("./constants");

const toByteArray = (str) => {
  let utf8Encode = new TextEncoder();
  return utf8Encode.encode(str)
}

const fromByteArray = (byteArray) => {
  let utf8Decode = new TextDecoder();
  return utf8Decode.decode(byteArray)
}

// chaacter @
const PAD_CHAR = 64;
const MAX_CLAIM_LEN = 75;
const NULL_CHAR = 128;

const findClaimLocation = (jwt, claim) => {
  const jwtBytes = toByteArray(jwt);
  let claimBytes = toByteArray(claim);

  // generate the text at all possible possible version
  let clean_test = btoa(fromByteArray(userId));
  let colon_at_0_index = btoa(fromByteArray(new Uint8Array([58, ...userId])));
  // add two character infront
  let offset_2 = btoa(fromByteArray(new Uint8Array([58, 34, ...userId])));
  let offset_0_1 = btoa(fromByteArray(new Uint8Array([...userId, 44])));
  let offset_1_1 = btoa(fromByteArray(new Uint8Array([34, ...userId, 34])));
  let offset_1_1_i = btoa(fromByteArray(new Uint8Array([58, ...userId, 44])));

  // remove 4 bytes from start and end of offset_1 and offset_2
  offset_1 = offset_1.slice(4).slice(0, -4);
  offset_2 = offset_2.slice(4).slice(0, -4);

  const versions = [offset_0, offset_1, offset_2];
  let claimLocation;
  let isPadded = 0;
  let offset = 0;

  for (let i = 0; i < versions.length; i++) {
    if(jwt.indexOf(versions[i]) !== -1) {
      claimLocation = jwt.indexOf(versions[i]);
      offset = i;
      
      if(i > 0) {
        isPadded = 1;
      }
      break;
    }
  }

  // Assert that that offset_0 is indeed part of the encoded jwt
  const actual = toByteArray(versions[offset]);
  for (let i = claimLocation, j = 0; i < claimLocation + actual.length; i++, j++) {
    assert(jwtBytes[i] === actual[j]);
  }

  claimBytes = Array.from(claimBytes)
  for(let i = 0; i < offset; i++) {
    claimBytes.unshift(PAD_CHAR);
  }

  const len = claimBytes.length;
  claimBytes = [...claimBytes, ...new Array(Math.max(MAX_CLAIM_LEN - len, 0)).fill(NULL_CHAR)];

  return [claimBytes.map(v => v.toString()), claimLocation, isPadded, offset]
}

module.exports = {findClaimLocation};
