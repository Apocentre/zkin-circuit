const constants = require("./constants");

const getJwtBytes = (jwt) => {
  const bytes = new TextEncoder().encode(jwt);
  const remaining = Math.max(constants.MAX_JWT_BYTES - bytes.length, 0);

  return [...bytes, ...new Array(remaining).fill(constants.NULL_CHAR)]
}

module.exports = {getJwtBytes}
