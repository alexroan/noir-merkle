use dep::std;

// Returns the root of the tree from the provided leaf and its hashpath, using mimc hash
fn compute_root_from_leaf(leaf : Field, index : Field, hash_path: [Field]) -> Field {
    let n = hash_path.len();
    let index_bits = index.to_le_bits(n as u32);
    let mut current = leaf;
    for i in 0..n {
        let path_bit = index_bits[i] as bool;
        let (hash_left, hash_right) = if path_bit {
            (hash_path[i], current)
        } else {
            (current, hash_path[i])
        };

        current = std::hash::mimc_bn254([hash_left, hash_right]);
    };
    current
}

fn main(
  recipient: pub Field,
  // Private key of note
  // all notes have the same denomination
  priv_key: Field, 
  // Merkle membership proof
  note_root: pub Field, 
  index: Field,
  note_hash_path: [Field; 3],
  // Random secret to keep note_commitment private
  secret: Field,
  // Hash to be checked against the nullifier computed in the circuit
  nullifierHash: pub Field, 
) -> pub Field {
    // Compute public key from private key to show ownership
    let pubkey = std::scalar_mul::fixed_base(priv_key);
    let pubkey_x = pubkey[0];
    let pubkey_y = pubkey[1];
    
    // Compute input note commitment
    let note_commitment = std::hash::pedersen([pubkey_x, pubkey_y, secret]);
    
    // Compute input note nullifier
    let nullifier = std::hash::pedersen([note_commitment[0], index, priv_key]);
    assert(nullifierHash == nullifier[0]);

    // Check that the input note commitment is in the root
    let new_root = compute_root_from_leaf(note_commitment[0], index, note_hash_path);
    assert(new_root == note_root);
    
    // Cannot have unused variables, return the recipient as public output of the circuit
    recipient
}

#[test]
fn test_main() {
    let recipient: Field = 0x00000000000000000000000070997970c51812dc3a010c7d01b50e0d17dc79c8;
    let priv_key: Field = 0x000000000000000000000000000000000000000000000000000000616c696365;
    let note_root: Field = 0x0f72910fa39249cc44881a98f91cde964f1ae2694dd627973b9578984f0f7a94;
    let index: Field = 0;
    let note_hash_path: [Field; 3] = [
        0x18d85f3de6dcd78b6ffbf5d8374433a5528d8e3bf2100df0b7bb43a4c59ebd63,
        0x1b7ba1a4ebccefab74ac08030f380fbeb0a005c73c75069e4d08fbb67d4984b9,
        0x0f40f15ccd167735cd35e2ee6390231f40433cf748434e7a0e8b26a95d96bf2d
    ];
    let secret: Field = 0x1929ea3ab8d9106a899386883d9428f8256cfedb3c4f6b66bf4aa4d28a79988f;
    let nullifierHash: Field = 0x22074c34b69bb85c360e2e8cc02a7a223388ba735aa1cf0bf8d0163b960e5876;

    main(
        recipient,
        priv_key,
        note_root,
        index,
        note_hash_path,
        secret,
        nullifierHash
    );
}