const nodeForge = require("node-forge");
const jwks = require("jwks-rsa");

const getPubkey = async (jwt) => {
  const header = JSON.parse(atob(jwt.split(".")[0]));
  const google_jwks = jwks({
    jwksUri: "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com",
  });

  const key = await google_jwks.getSigningKey(header.kid);
  const signingKey = key.getPublicKey();
  const pubKeyData = nodeForge.pki.publicKeyFromPem(signingKey);
  const modulus = BigInt(pubKeyData.n.toString());

  return modulus;
}

module.exports = {getPubkey}
