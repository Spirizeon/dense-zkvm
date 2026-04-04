use wasm_bindgen::prelude::*;

use crate::client::prover::{ClientWitness, DenseClient};
use crate::prover::local::LocalProver;
use crate::rel1cs::types::PublicInputs;

#[wasm_bindgen(start)]
pub fn init() {
    console_error_panic_hook::set_once();
}

#[wasm_bindgen]
pub struct WasmClient {
    inner: DenseClient,
}

#[wasm_bindgen]
impl WasmClient {
    #[wasm_bindgen(constructor)]
    pub fn new() -> WasmClient {
        WasmClient {
            inner: DenseClient::new(),
        }
    }

    pub fn create_witness(
        &mut self,
        sender: u64,
        receiver: u64,
        weight: u64,
    ) -> Result<String, JsError> {
        let witness = self
            .inner
            .create_witness(sender, receiver, weight)
            .map_err(|e| JsError::new(&format!("{}", e)))?;
        Ok(serde_json::to_string(&witness).unwrap())
    }
}

#[wasm_bindgen]
pub struct WasmProver {
    inner: LocalProver,
}

#[wasm_bindgen]
impl WasmProver {
    #[wasm_bindgen(constructor)]
    pub fn new() -> Result<WasmProver, JsError> {
        let inner = LocalProver::setup().map_err(|e| JsError::new(&format!("{}", e)))?;
        Ok(WasmProver { inner })
    }

    pub fn prove(&self, witness_json: &str, public_inputs_json: &str) -> Result<String, JsError> {
        let witness: ClientWitness =
            serde_json::from_str(witness_json).map_err(|e| JsError::new(&e.to_string()))?;
        let public_inputs: PublicInputs =
            serde_json::from_str(public_inputs_json).map_err(|e| JsError::new(&e.to_string()))?;

        let proof = self
            .inner
            .prove(witness, public_inputs)
            .map_err(|e| JsError::new(&format!("{}", e)))?;

        Ok(serde_json::to_string(&proof).unwrap())
    }
}

#[wasm_bindgen]
pub fn execute_flow(
    sender: u64,
    receiver: u64,
    weight: u64,
    graph_root: &str,
    threshold: u64,
) -> Result<String, JsError> {
    let mut client = DenseClient::new();
    let witness = client
        .create_witness(sender, receiver, weight)
        .map_err(|e| JsError::new(&format!("{}", e)))?;

    let public_inputs = PublicInputs {
        graph_root: graph_root.to_string(),
        threshold,
    };

    let prover = LocalProver::setup().map_err(|e| JsError::new(&format!("{}", e)))?;
    let proof = prover
        .prove(witness, public_inputs)
        .map_err(|e| JsError::new(&format!("{}", e)))?;

    Ok(serde_json::to_string(&proof).unwrap())
}
