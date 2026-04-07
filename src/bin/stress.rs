use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::thread;
use std::time::Instant;

use densezk_sdk::{DenseClient, LocalProver, PublicInputs};

const NUM_THREADS: usize = 32;
const PROOFS_PER_THREAD: usize = 500;

static TOTAL_PROOFS: AtomicU64 = AtomicU64::new(0);
static TOTAL_ERRORS: AtomicU64 = AtomicU64::new(0);
static STOP: AtomicBool = AtomicBool::new(false);

fn main() {
    println!("=== DenseZK Stress Test ===");
    println!("Threads:       {}", NUM_THREADS);
    println!("Proofs/thread: {}", PROOFS_PER_THREAD);
    println!("Total proofs:  {}", NUM_THREADS * PROOFS_PER_THREAD);
    println!();

    let start = Instant::now();
    let mut handles = Vec::new();

    for t in 0..NUM_THREADS {
        let handle = thread::spawn(move || {
            for i in 0..PROOFS_PER_THREAD {
                if STOP.load(Ordering::Relaxed) {
                    break;
                }

                let sender = (t * PROOFS_PER_THREAD + i) as u64;
                let receiver = sender.wrapping_mul(7).wrapping_add(13);
                let weight = (i % 100) as u64 + 1;

                let mut client = DenseClient::new();
                let witness = match client.create_witness(sender, receiver, weight) {
                    Ok(w) => w,
                    Err(e) => {
                        eprintln!("[thread {}] witness failed: {}", t, e);
                        TOTAL_ERRORS.fetch_add(1, Ordering::Relaxed);
                        continue;
                    }
                };

                let public_inputs = PublicInputs {
                    graph_root: format!("0xroot_{:08x}", sender),
                    threshold: weight,
                };

                let prover = match LocalProver::setup() {
                    Ok(p) => p,
                    Err(e) => {
                        eprintln!("[thread {}] setup failed: {}", t, e);
                        TOTAL_ERRORS.fetch_add(1, Ordering::Relaxed);
                        STOP.store(true, Ordering::Relaxed);
                        break;
                    }
                };

                match prover.prove(witness, public_inputs) {
                    Ok(_proof) => {
                        TOTAL_PROOFS.fetch_add(1, Ordering::Relaxed);
                        let count = TOTAL_PROOFS.load(Ordering::Relaxed);
                        if count % 10 == 0 {
                            let elapsed = start.elapsed();
                            let rate = count as f64 / elapsed.as_secs_f64();
                            println!(
                                "[progress] proof #{} | rate: {:.2} proofs/s | elapsed: {:.1}s",
                                count,
                                rate,
                                elapsed.as_secs_f64()
                            );
                        }
                    }
                    Err(e) => {
                        eprintln!("[thread {}] prove failed: {}", t, e);
                        TOTAL_ERRORS.fetch_add(1, Ordering::Relaxed);
                    }
                }
            }
        });
        handles.push(handle);
    }

    for handle in handles {
        let _ = handle.join();
    }

    let elapsed = start.elapsed();
    let proofs = TOTAL_PROOFS.load(Ordering::Relaxed);
    let errors = TOTAL_ERRORS.load(Ordering::Relaxed);
    let rate = proofs as f64 / elapsed.as_secs_f64();

    println!();
    println!("=== Results ===");
    println!("Proofs:     {}", proofs);
    println!("Errors:     {}", errors);
    println!("Time:       {:.2}s", elapsed.as_secs_f64());
    println!("Throughput: {:.2} proofs/s", rate);
    println!(
        "Avg time:   {:.2}ms/proof",
        elapsed.as_millis() as f64 / proofs.max(1) as f64
    );
}
