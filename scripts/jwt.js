const assert = require("assert");
const constants = require("./constants");

const getJwtBytes = (jwt) => {
  const bytes = new TextEncoder().encode(jwt);
  const remaining = Math.max(constants.MAX_JWT_BYTES - bytes.length, 0);

  return [...bytes, ...new Array(remaining).fill(constants.NULL_CHAR)]
}

const getClaimByteArray = (claim) => {
  const bytes = new TextEncoder().encode(claim);
  const remaining = Math.max(constants.MAX_CLAIM_LEN - bytes.length, 0);

  return [...bytes, ...new Array(remaining).fill(constants.NULL_CHAR)]
}


const padJwtHeader = (jwt) => {
  const jwtLen = jwt.length;
  const dotIndex = jwt.indexOf(constants.DOT_BYTE);
  assert(dotIndex !== -1);
  
  const header = jwt.slice(0, dotIndex);
  const padCount = header.length % 4;
  const paddedHeader = [...header, ...new Array(padCount).fill(constants.HEADER_PADDING)]

  return [
    dotIndex + padCount,
    padCount,
    [...paddedHeader, ...jwt.slice(dotIndex + 1, jwtLen - padCount + 1)],
  ]
}

module.exports = {getJwtBytes, getClaimByteArray, padJwtHeader}
