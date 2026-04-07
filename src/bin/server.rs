use actix_cors::Cors;
use actix_web::{
    get, post, web, App, HttpResponse, HttpServer, Responder,
    middleware::Logger,
};
use densezk_sdk::{DenseClient, LocalProver, PublicInputs};
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicU64, Ordering};
use std::time::Instant;

static REQUEST_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Deserialize)]
struct WitnessRequest {
    sender_id: u64,
    receiver_id: u64,
    weight: u64,
}

#[derive(Deserialize)]
struct ProveRequest {
    sender_id: u64,
    receiver_id: u64,
    weight: u64,
    graph_root: String,
    threshold: u64,
}

#[derive(Deserialize)]
struct PoseidonRequest {
    sender_id: u64,
    receiver_id: u64,
    weight: u64,
}

#[derive(Serialize)]
struct WitnessResponse {
    edge: EdgeData,
    commitment: String,
}

#[derive(Serialize)]
struct EdgeData {
    sender_id: u64,
    receiver_id: u64,
    weight: u64,
}

#[derive(Serialize)]
struct ProofResponse {
    proof_bytes: Vec<u8>,
    root_commitment: String,
}

#[derive(Serialize)]
struct PoseidonResponse {
    hash: String,
}

#[derive(Serialize)]
struct HealthResponse {
    status: String,
    uptime_seconds: u64,
    total_requests: u64,
}

#[derive(Serialize)]
struct ErrorResponse {
    error: String,
}

fn error_response(msg: &str) -> HttpResponse {
    HttpResponse::InternalServerError().json(ErrorResponse {
        error: msg.to_string(),
    })
}

#[get("/health")]
async fn health() -> impl Responder {
    let start = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();
    HttpResponse::Ok().json(HealthResponse {
        status: "ok".to_string(),
        uptime_seconds: start,
        total_requests: REQUEST_COUNT.load(Ordering::Relaxed),
    })
}

#[post("/witness")]
async fn create_witness(req: web::Json<WitnessRequest>) -> impl Responder {
    REQUEST_COUNT.fetch_add(1, Ordering::Relaxed);
    let timer = Instant::now();

    let mut client = DenseClient::new();
    match client.create_witness(req.sender_id, req.receiver_id, req.weight) {
        Ok(witness) => {
            let elapsed = timer.elapsed().as_millis();
            log::info!("Witness created in {}ms", elapsed);
            HttpResponse::Ok().json(WitnessResponse {
                edge: EdgeData {
                    sender_id: req.sender_id,
                    receiver_id: req.receiver_id,
                    weight: req.weight,
                },
                commitment: witness.commitment.to_string(),
            })
        }
        Err(e) => {
            log::error!("Witness creation failed: {}", e);
            error_response(&e.to_string())
        }
    }
}

#[post("/prove")]
async fn prove(req: web::Json<ProveRequest>) -> impl Responder {
    REQUEST_COUNT.fetch_add(1, Ordering::Relaxed);
    let timer = Instant::now();

    let mut client = DenseClient::new();
    let witness = match client.create_witness(req.sender_id, req.receiver_id, req.weight) {
        Ok(w) => w,
        Err(e) => {
            log::error!("Witness creation failed: {}", e);
            return error_response(&e.to_string());
        }
    };

    let public_inputs = PublicInputs {
        graph_root: req.graph_root.clone(),
        threshold: req.threshold,
    };

    let prover = match LocalProver::setup() {
        Ok(p) => p,
        Err(e) => {
            log::error!("Prover setup failed: {}", e);
            return error_response(&e.to_string());
        }
    };

    match prover.prove(witness, public_inputs) {
        Ok(proof) => {
            let elapsed = timer.elapsed().as_millis();
            log::info!("Proof generated in {}ms ({} bytes)", elapsed, proof.proof_bytes.len());
            HttpResponse::Ok().json(ProofResponse {
                proof_bytes: proof.proof_bytes,
                root_commitment: proof.root_commitment,
            })
        }
        Err(e) => {
            log::error!("Proof generation failed: {}", e);
            error_response(&e.to_string())
        }
    }
}

#[post("/execute_flow")]
async fn execute_flow(req: web::Json<ProveRequest>) -> impl Responder {
    REQUEST_COUNT.fetch_add(1, Ordering::Relaxed);
    let timer = Instant::now();

    match densezk_sdk::execute_dense_zk_flow(
        req.sender_id,
        req.receiver_id,
        req.weight,
        &req.graph_root,
        req.threshold,
    ) {
        Ok(proof) => {
            let elapsed = timer.elapsed().as_millis();
            log::info!("Full flow executed in {}ms", elapsed);
            HttpResponse::Ok().json(ProofResponse {
                proof_bytes: proof.proof_bytes,
                root_commitment: proof.root_commitment,
            })
        }
        Err(e) => {
            log::error!("Flow execution failed: {}", e);
            error_response(&e.to_string())
        }
    }
}

#[post("/poseidon_hash")]
async fn poseidon_hash(req: web::Json<PoseidonRequest>) -> impl Responder {
    REQUEST_COUNT.fetch_add(1, Ordering::Relaxed);

    let mut client = DenseClient::new();
    match client.create_witness(req.sender_id, req.receiver_id, req.weight) {
        Ok(witness) => HttpResponse::Ok().json(PoseidonResponse {
            hash: witness.commitment.to_string(),
        }),
        Err(e) => error_response(&e.to_string()),
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    let host = std::env::var("DENSEZK_HOST").unwrap_or_else(|_| "0.0.0.0".to_string());
    let port = std::env::var("DENSEZK_PORT").unwrap_or_else(|_| "8080".to_string());
    let addr = format!("{}:{}", host, port);

    log::info!("Starting DenseZK server on {}", addr);
    log::info!("Endpoints:");
    log::info!("  GET  /health          - Server health check");
    log::info!("  POST /witness         - Create witness (Poseidon commitment)");
    log::info!("  POST /prove           - Generate ZK proof");
    log::info!("  POST /execute_flow    - Full witness + prove flow");
    log::info!("  POST /poseidon_hash   - Hash graph edge");

    HttpServer::new(|| {
        let cors = Cors::default()
            .allow_any_origin()
            .allow_any_method()
            .allow_any_header();

        App::new()
            .wrap(cors)
            .wrap(Logger::default())
            .service(health)
            .service(create_witness)
            .service(prove)
            .service(execute_flow)
            .service(poseidon_hash)
    })
    .bind(&addr)?
    .run()
    .await
}
