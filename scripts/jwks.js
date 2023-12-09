import nodeForge from "node-forge";
import jwks from "jwks-rsa";

export const getPubkey = async (jwt) => {
  const header = JSON.parse(atob(jwt.split(".")[0]));
  const google_jwks = jwks({
    jwksUri: "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com",
  });

  const key = await google_jwks.getSigningKey(header.kid);
  const signingKey = key.getPublicKey();
  const pubKeyData = nodeForge.pki.publicKeyFromPem(signingKey);
  const modulus = BigInt(pubKeyData.n.toString());

  console.log(pubKeyData.n.data.length)

  return modulus;
}
