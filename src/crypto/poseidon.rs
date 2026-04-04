use crate::error::DenseZKError;
use ark_bn254::Fr;
use ark_ff::PrimeField;
use light_poseidon::{Poseidon, PoseidonHasher as LPoseidonHasher};

pub struct PoseidonHasher {
    hasher: Poseidon<Fr>,
}

impl PoseidonHasher {
    pub fn new() -> Self {
        Self {
            hasher: Poseidon::<Fr>::new_circom(3).expect("Failed to create Poseidon hasher"),
        }
    }

    pub fn hash_edge(
        &mut self,
        sender: u64,
        receiver: u64,
        weight: u64,
    ) -> Result<String, DenseZKError> {
        let inputs = vec![Fr::from(sender), Fr::from(receiver), Fr::from(weight)];

        let hash_result = self
            .hasher
            .hash(&inputs)
            .map_err(|_| DenseZKError::ConstraintViolation)?;
        Ok(format!("{:?}", hash_result.into_bigint()))
    }
}
