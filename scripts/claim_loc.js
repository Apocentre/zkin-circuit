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

const findClaimLocation = (jwt, claim) => {
  const jwtBytes = toByteArray(jwt);

  // generate the text at all possible possible version
  let clean_test = btoa(claim).replaceAll("=", "");
  let quote_at_0_index = btoa(fromByteArray(new Uint8Array([QUOTE_ASCII, ...claim]))).replaceAll("=", "");
  let colon_at_0_index = btoa(fromByteArray(new Uint8Array([COLON_ASCII, ...claim]))).replaceAll("=", "");
  let colon_and_quote_at_start = btoa(fromByteArray(new Uint8Array([COLON_ASCII, QUOTE_ASCII, ...claim]))).replaceAll("=", "");
  let comma_at_the_end = btoa(fromByteArray(new Uint8Array([...claim, COMMA_ASCII]))).replaceAll("=", "");
  let quote_at_start_and_end = btoa(fromByteArray(new Uint8Array([QUOTE_ASCII, ...claim, QUOTE_ASCII]))).replaceAll("=", "");
  let quote_and_comma_at_end = btoa(fromByteArray(new Uint8Array([...claim, QUOTE_ASCII, COMMA_ASCII]))).replaceAll("=", "");
  let comma_and_quote_at_end = btoa(fromByteArray(new Uint8Array([...claim, COMMA_ASCII, QUOTE_ASCII]))).replaceAll("=", "");
  let colon_at_start_and_comma_at_end = btoa(fromByteArray(new Uint8Array([COLON_ASCII, ...claim, COMMA_ASCII]))).replaceAll("=", "");

  const versions = [
    clean_test, quote_at_0_index, colon_at_0_index, colon_and_quote_at_start, comma_at_the_end, quote_at_start_and_end,
    quote_and_comma_at_end, comma_and_quote_at_end, colon_at_start_and_comma_at_end,
  ];

  let claimLocation;
  let version = 0;

  for (let i = 0; i < versions.length; i++) {
    if(jwt.indexOf(versions[i]) !== -1) {
      claimLocation = jwt.indexOf(versions[i]);
      version = versions[i];
      break;
    }
  }

  const claimBytes = toByteArray(version);
  for (let i = claimLocation, j = 0; i < claimLocation + actual.length; i++, j++) {
    assert(jwtBytes[i] === actual[j]);
  }

  const len = claimBytes.length;
  claimBytes = [...claimBytes, ...new Array(Math.max(MAX_CLAIM_BYTES - len, 0)).fill(0)];

  return [claimBytes.map(v => v.toString()), claimLocation]
}

module.exports = {findClaimLocation};
