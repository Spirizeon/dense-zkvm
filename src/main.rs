use densezk_sdk::execute_dense_zk_flow;

fn main() {
    let result = execute_dense_zk_flow(456, 789, 1, "0xabc123", 1);

    match result {
        Ok(proof) => println!(
            "Proof generated locally, size: {} bytes",
            proof.proof_bytes.len()
        ),
        Err(e) => eprintln!("Error during execution: {}", e),
    }
}
