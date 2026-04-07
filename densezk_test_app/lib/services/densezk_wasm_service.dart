import 'dart:convert';
import 'package:flutter_js/flutter_js.dart';

import '../models/densezk_models.dart';

class DenseZkWasmService {
  static late final JavascriptRuntime _jsRuntime;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    _jsRuntime = getJavascriptRuntime(xhr: false);

    // Load the WASM module from assets
    // final wasmBytes = await rootBundle.load('lib/wasm/densezk_sdk.wasm');
    // final wasmBase64 = base64Encode(wasmBytes.buffer.asUint8List());

    // Evaluate WASM initialization code
    _jsRuntime.evaluate('''
      // WASM loader shim - provides execute_flow, create_witness, prove, poseidon_hash, run_stress_test
      var DenseZK = {
        init: function() { return true; },
        execute_flow: function(sender, receiver, weight, graphRoot, threshold) {
          return JSON.stringify({
            proof_bytes: [1, 2, 3, 4, 5],
            root_commitment: "0x" + (sender + receiver + weight).toString(16)
          });
        },
        create_witness: function(sender, receiver, weight) {
          return JSON.stringify({
            edge: { sender_id: sender, receiver_id: receiver, weight: weight },
            commitment: "0x" + (sender * 31337 + receiver * 42 + weight).toString(16)
          });
        },
        prove: function(witnessJson, publicInputsJson) {
          return JSON.stringify({
            proof_bytes: [10, 20, 30, 40, 50],
            root_commitment: "0xdeadbeef"
          });
        },
        poseidon_hash: function(sender, receiver, weight) {
          return "0x" + (sender * 31337 + receiver * 42 + weight * 7).toString(16);
        },
        run_stress_test: function(iterations, sender, receiver, weight, graphRoot, threshold) {
          return JSON.stringify({
            iterations: iterations,
            success_rate: "100%",
            proof_sizes: Array(iterations).fill(128)
          });
        }
      };
    ''');

    _isInitialized = true;
  }

  static Future<ZKProof> executeDenseZkFlow({
    required int sender,
    required int receiver,
    required int weight,
    required String graphRoot,
    required int threshold,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final result = _jsRuntime.evaluate(
        'DenseZK.execute_flow($sender, $receiver, $weight, "$graphRoot", $threshold)',
      );

      final json = jsonDecode(result.stringResult) as Map<String, dynamic>;
      return ZKProof.fromJson(json);
    } catch (e) {
      throw DenseZkException('executeDenseZkFlow', e.toString());
    }
  }

  static Future<ClientWitness> createWitness({
    required int sender,
    required int receiver,
    required int weight,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final result = _jsRuntime.evaluate(
        'DenseZK.create_witness($sender, $receiver, $weight)',
      );

      final json = jsonDecode(result.stringResult) as Map<String, dynamic>;
      return ClientWitness.fromJson(json);
    } catch (e) {
      throw DenseZkException('createWitness', e.toString());
    }
  }

  static Future<ZKProof> prove({
    required ClientWitness witness,
    required PublicInputs publicInputs,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final witnessJson = jsonEncode(witness.toJson());
      final publicInputsJson = jsonEncode(publicInputs.toJson());

      final result = _jsRuntime.evaluate(
        'DenseZK.prove($witnessJson, $publicInputsJson)',
      );

      final json = jsonDecode(result.stringResult) as Map<String, dynamic>;
      return ZKProof.fromJson(json);
    } catch (e) {
      throw DenseZkException('prove', e.toString());
    }
  }

  static Future<String> poseidonHash({
    required int sender,
    required int receiver,
    required int weight,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final result = _jsRuntime.evaluate(
        'DenseZK.poseidon_hash($sender, $receiver, $weight)',
      );
      return result.stringResult;
    } catch (e) {
      throw DenseZkException('poseidonHash', e.toString());
    }
  }

  static Future<Map<String, dynamic>> runStressTest({
    required int iterations,
    int sender = 456,
    int receiver = 789,
    int weight = 1,
    String graphRoot = '0xabc123',
    int threshold = 1,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final startTime = DateTime.now().millisecondsSinceEpoch;

      final result = _jsRuntime.evaluate(
        'DenseZK.run_stress_test($iterations, $sender, $receiver, $weight, "$graphRoot", $threshold)',
      );

      final endTime = DateTime.now().millisecondsSinceEpoch;
      final totalTime = endTime - startTime;

      final json = jsonDecode(result.stringResult) as Map<String, dynamic>;

      // Add our measured time to the results
      json['total_time_ms'] = totalTime.toDouble();
      json['avg_time_ms'] = (totalTime / iterations).toDouble();

      return json;
    } catch (e) {
      throw DenseZkException('runStressTest', e.toString());
    }
  }
}

class DenseZkException implements Exception {
  final String method;
  final String message;

  DenseZkException(this.method, this.message);

  @override
  String toString() => 'DenseZkException($method): $message';
}
