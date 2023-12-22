echo "Compiling zkin.circom..."

circom circuits/zkin.circom  --r1cs --sym --wasm -o build -l node_modules

PTAU = 21

if [ -f ./ptau/powersOfTau28_hez_final_${PTAU}.ptau ]; then
    echo "----- powersOfTau28_hez_final_${PTAU}.ptau already exists -----"
else
    echo "----- Download powersOfTau28_hez_final_${PTAU}.ptau -----"
    wget -P ./ptau https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_${PTAU}.ptau
fi

cd build/zkin_js
node generate_witness.js zkin.wasm ../../inputs/zkin.json witness.wtns

# Copy the witness.wtns to the outside and go there
cp witness.wtns ../witness.wtns
cd ..

# Start a new powers of tau ceremony
snarkjs powersoftau new bn128 21 pot21_0000.ptau -v

# Contribute to the ceremony
snarkjs powersoftau contribute pot21_0000.ptau pot21_0001.ptau --name="First contribution" -v

# Start generating th phase 2
snarkjs powersoftau prepare phase2 pot21_0001.ptau pot21_final.ptau -v

# Generate a .zkey file that will contain the proving and verification keys together with all phase 2 contributions
snarkjs groth16 setup zkin.r1cs pot21_final.ptau ZkIn_0000.zkey

# Contribute to the phase 2 of the ceremony
snarkjs zkey contribute ZkIn_0000.zkey ZkIn_0001.zkey --name="1st Contributor Name" -v

# Export the verification key
snarkjs zkey export verificationkey ZkIn_0001.zkey verification_key.json

# Generate a zk-proof associated to the circuit and the witness. This generates proof.json and public.json
snarkjs groth16 prove ZkIn_0001.zkey witness.wtns proof.json public.json

# Verify the proof
snarkjs groth16 verify verification_key.json public.json proof.json

# Generate a Solidity verifier that allows verifying proofs on Ethereum blockchain
snarkjs zkey export solidityverifier ZkIn_0001.zkey ../contracts/ZkInVerifier.sol

# Generate and print parameters of call
snarkjs generatecall | tee parameters.txt
