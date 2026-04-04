export interface GraphEdge {
  sender_id: number;
  receiver_id: number;
  weight: number;
}

export interface PublicInputs {
  graph_root: string;
  threshold: number;
}

export interface ClientWitness {
  edge: GraphEdge;
  commitment: string;
}

export interface ZKProof {
  proof_bytes: number[];
  root_commitment: string;
}

export interface DenseZKError {
  message: string;
}
