import {
  GraphEdge,
  PublicInputs,
  ClientWitness,
  ZKProof,
} from './types';

let wasmModule: any = null;
let wasmClient: any = null;
let wasmProver: any = null;

async function loadWasm(): Promise<void> {
  if (wasmModule) return;

  const wasm = await import('../pkg/densezk_sdk.js');
  wasm.init();
  wasmModule = wasm;
}

export async function init(): Promise<void> {
  await loadWasm();
}

export function createClient(): Client {
  if (!wasmModule) {
    throw new Error('WASM module not loaded. Call init() first.');
  }
  return new Client();
}

export function createProver(): Prover {
  if (!wasmModule) {
    throw new Error('WASM module not loaded. Call init() first.');
  }
  return new Prover();
}

export async function executeFlow(
  sender: number,
  receiver: number,
  weight: number,
  graphRoot: string,
  threshold: number,
): Promise<ZKProof> {
  await loadWasm();

  const result = wasmModule.execute_flow(
    BigInt(sender),
    BigInt(receiver),
    BigInt(weight),
    graphRoot,
    BigInt(threshold),
  );

  return JSON.parse(result) as ZKProof;
}

export class Client {
  private inner: any;

  constructor() {
    if (!wasmModule) {
      throw new Error('WASM module not loaded. Call init() first.');
    }
    this.inner = new wasmModule.WasmClient();
  }

  createWitness(
    sender: number,
    receiver: number,
    weight: number,
  ): ClientWitness {
    const witnessJson = this.inner.create_witness(
      BigInt(sender),
      BigInt(receiver),
      BigInt(weight),
    );
    return JSON.parse(witnessJson) as ClientWitness;
  }
}

export class Prover {
  private inner: any;

  constructor() {
    if (!wasmModule) {
      throw new Error('WASM module not loaded. Call init() first.');
    }
    this.inner = new wasmModule.WasmProver();
  }

  prove(witness: ClientWitness, publicInputs: PublicInputs): ZKProof {
    const witnessJson = JSON.stringify(witness);
    const publicInputsJson = JSON.stringify(publicInputs);
    const result = this.inner.prove(witnessJson, publicInputsJson);
    return JSON.parse(result) as ZKProof;
  }
}
