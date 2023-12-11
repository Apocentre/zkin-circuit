const splitJWT = (jwt) => {
  const result = [];
  let i = 0;

  while (jwt.length) {
    i++;
    const chunk = jwt.splice(0, 16);
    result.push(chunk);
  }

  return result
}

module.exports = {splitJWT}
