# API Reference

Complete reference for all public types and functions in the DenseZK SDK.

## Re-exports

The crate root re-exports the most commonly used types:

```rust
pub use client::prover::DenseClient;
pub use prover::local::{LocalProver, ZKProof};
pub use rel1cs::types::{GraphEdge, PublicInputs};
pub use error::DenseZKError;
```

## Functions

### `execute_dense_zk_flow`

```rust
pub fn execute_dense_zk_flow(
    sender: u64,
    receiver: u64,
    weight: u64,
    graph_root: &str,
    threshold: u64,
) -> Result<ZKProof, DenseZKError>
```

End-to-end convenience function. Generates a witness on-device and runs local Groth16 proving.

**Parameters:**

| Parameter | Description |
|---|---|
| `sender` | Sender node ID in the social graph |
| `receiver` | Receiver node ID in the social graph |
| `weight` | Edge weight |
| `graph_root` | Current Merkle root of the graph state |
| `threshold` | Predicate threshold value |

**Returns:** `ZKProof` on success, `DenseZKError` on failure.

**Errors:**

- `WitnessGenerationFailed` -- Poseidon hashing or proof serialization failed
- `SerializationError` -- JSON encoding or decoding failed
- `ConstraintViolation` -- R1CS constraint not satisfied or proof verification failed
- `SetupFailed` -- Groth16 circuit-specific setup failed

### `execute_flow` (WASM)

```rust
pub fn execute_flow(
    sender: u64,
    receiver: u64,
    weight: u64,
    graph_root: &str,
    threshold: u64,
) -> Result<String, JsError>
```

One-shot WASM entry point. Returns a JSON string of the proof.

---

## Structs

### `DenseClient`

On-device witness generator.

```rust
pub struct DenseClient { /* private */ }
```

#### `DenseClient::new`

```rust
pub fn new() -> Self
```

Creates a new client with a fresh Poseidon hasher configured for 3-input BN254 hashing.

#### `DenseClient::create_witness`

```rust
pub fn create_witness(
    &mut self,
    sender: u64,
    receiver: u64,
    weight: u64,
) -> Result<ClientWitness, DenseZKError>
```

Generates a witness by hashing the graph edge with Poseidon.

**Parameters:**

| Parameter | Description |
|---|---|
| `sender` | Sender node ID |
| `receiver` | Receiver node ID |
| `weight` | Edge weight |

**Returns:** `ClientWitness` containing the edge and Poseidon commitment.

**Errors:**

- `ConstraintViolation` -- Poseidon hashing failed

---

### `WasmClient` (WASM)

WASM wrapper around `DenseClient`. Exposes `create_witness` returning a JSON string.

```rust
#[wasm_bindgen]
pub struct WasmClient { /* private */ }
```

#### `WasmClient::new`

```rust
#[wasm_bindgen(constructor)]
pub fn new() -> WasmClient
```

#### `WasmClient::create_witness`

```rust
pub fn create_witness(
    &mut self,
    sender: u64,
    receiver: u64,
    weight: u64,
) -> Result<String, JsError>
```

Returns a JSON-serialized `ClientWitness`.

---

### `ClientWitness`

```rust
pub struct ClientWitness {
    pub edge: GraphEdge,
    pub commitment: String,
}
```

The execution trace generated on-device. Implements `Serialize` and `Deserialize` for JSON transmission.

**Fields:**

| Field | Type | Description |
|---|---|---|
| `edge` | `GraphEdge` | The social edge |
| `commitment` | `String` | Hex-encoded Poseidon hash of the edge |

---

### `LocalProver`

Local Groth16 prover. Holds proving and verifying keys generated during setup.

```rust
pub struct LocalProver { /* private */ }
```

#### `LocalProver::setup`

```rust
pub fn setup() -> Result<Self, DenseZKError>
```

Performs circuit-specific trusted setup using a dummy circuit. Generates the proving key and verifying key for BN254 Groth16.

**Returns:** `LocalProver` ready for proving.

**Errors:**

- `SetupFailed` -- Setup could not complete

#### `LocalProver::prove`

```rust
pub fn prove(
    &self,
    witness: ClientWitness,
    public_inputs: PublicInputs,
) -> Result<ZKProof, DenseZKError>
```

Generates a Groth16 proof from the witness and public inputs, verifies it internally, and returns the serialized proof.

**Parameters:**

| Parameter | Description |
|---|---|
| `witness` | Client-generated witness |
| `public_inputs` | Public verification inputs |

**Returns:** `ZKProof` with 128-byte compressed proof.

**Errors:**

- `WitnessGenerationFailed` -- Proof generation or serialization failed
- `ConstraintViolation` -- Proof verification failed

---

### `WasmProver` (WASM)

WASM wrapper around `LocalProver`. Accepts and returns JSON strings.

```rust
#[wasm_bindgen]
pub struct WasmProver { /* private */ }
```

#### `WasmProver::new`

```rust
#[wasm_bindgen(constructor)]
pub fn new() -> Result<WasmProver, JsError>
```

#### `WasmProver::prove`

```rust
pub fn prove(
    &self,
    witness_json: &str,
    public_inputs_json: &str,
) -> Result<String, JsError>
```

Accepts JSON-serialized `ClientWitness` and `PublicInputs`. Returns JSON-serialized `ZKProof`.

---

### `ZKProof`

```rust
pub struct ZKProof {
    pub proof_bytes: Vec<u8>,
    pub root_commitment: String,
}
```

The proof result from local proving.

**Fields:**

| Field | Type | Description |
|---|---|---|
| `proof_bytes` | `Vec<u8>` | Compressed Groth16 proof (128 bytes for BN254) |
| `root_commitment` | `String` | The graph root passed as public input |

---

### `GraphEdge`

```rust
pub struct GraphEdge {
    pub sender_id: u64,
    pub receiver_id: u64,
    pub weight: u64,
}
```

Represents a directed, weighted edge in the social graph.

**Fields:**

| Field | Type | Description |
|---|---|---|
| `sender_id` | `u64` | Source node identifier |
| `receiver_id` | `u64` | Target node identifier |
| `weight` | `u64` | Edge weight |

---

### `PublicInputs`

```rust
pub struct PublicInputs {
    pub graph_root: String,
    pub threshold: u64,
}
```

Public values verified by the zk-SNARK verifier.

**Fields:**

| Field | Type | Description |
|---|---|---|
| `graph_root` | `String` | Merkle root of the graph state |
| `threshold` | `u64` | Predicate threshold |

---

### `PoseidonHasher`

```rust
pub struct PoseidonHasher { /* private */ }
```

Wrapper around `light_poseidon::Poseidon` for BN254 field hashing.

#### `PoseidonHasher::new`

```rust
pub fn new() -> Self
```

Creates a hasher with `Poseidon::<Fr>::new_circom(3)`.

#### `PoseidonHasher::hash_edge`

```rust
pub fn hash_edge(
    &mut self,
    sender: u64,
    receiver: u64,
    weight: u64,
) -> Result<String, DenseZKError>
```

Hashes three u64 values as BN254 field elements and returns the hex-encoded result.

**Errors:**

- `ConstraintViolation` -- Sponge operation failed

---

## Enums

### `DenseZKError`

```rust
pub enum DenseZKError {
    WitnessGenerationFailed,
    SerializationError(serde_json::Error),
    ConstraintViolation,
    SetupFailed,
}
```

Unified error type for all SDK operations.

**Variants:**

| Variant | Description |
|---|---|
| `WitnessGenerationFailed` | Witness generation or proof serialization failed |
| `SerializationError` | Wraps `serde_json::Error` from JSON operations |
| `ConstraintViolation` | R1CS constraint not satisfied or proof verification failed |
| `SetupFailed` | Groth16 circuit-specific setup failed |

---

## React Native TypeScript API

### `init()`

```typescript
export async function init(): Promise<void>
```

Loads the WASM module. Must be called before any other function.

### `executeFlow()`

```typescript
export async function executeFlow(
  sender: number,
  receiver: number,
  weight: number,
  graphRoot: string,
  threshold: number,
): Promise<ZKProof>
```

One-shot proof generation. Loads WASM if not already loaded.

### `Client` class

```typescript
export class Client {
  constructor()
  createWitness(sender: number, receiver: number, weight: number): ClientWitness
}
```

### `Prover` class

```typescript
export class Prover {
  constructor()
  prove(witness: ClientWitness, publicInputs: PublicInputs): ZKProof
}
```

### TypeScript Types

```typescript
interface GraphEdge {
  sender_id: number;
  receiver_id: number;
  weight: number;
}

interface PublicInputs {
  graph_root: string;
  threshold: number;
}

interface ClientWitness {
  edge: GraphEdge;
  commitment: string;
}

interface ZKProof {
  proof_bytes: number[];
  root_commitment: string;
}
```
