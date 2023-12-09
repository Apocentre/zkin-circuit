import assert from "assert";

const toByteArray = (str) => {
  let utf8Encode = new TextEncoder();
  return utf8Encode.encode(str)
}

const fromByteArray = (byteArray) => {
  let utf8Decode = new TextDecoder();
  return utf8Decode.decode(byteArray)
}

// @
const PAD_CHAR = 64;
const MAX_CLAIM_LEN = 75;
const NULL_CHAR = 128;

export const findClaimLocation = (jwt, claim) => {
  const jwtBytes = toByteArray(jwt);
  let claimBytes = toByteArray(claim);

  // generate the text at all possible three-byte offsets, and remove the characters that might be influenced by the context
  let offset_0 = btoa(fromByteArray(claimBytes));
  // add one character infront. @ is 64 in decimal
  let offset_1 = btoa(fromByteArray(new Uint8Array([PAD_CHAR, ...claimBytes])));
  // add two character infront
  let offset_2 = btoa(fromByteArray(new Uint8Array([PAD_CHAR, PAD_CHAR, ...claimBytes])));

  // Adding three will have a strint that contains the offset_0 as a substring; So we don't need to take this into
  // account. We really have only three possbile version of the b64 encoded claim
  const offset_3 = btoa(fromByteArray(new Uint8Array([PAD_CHAR, PAD_CHAR, PAD_CHAR, ...claimBytes])));

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

