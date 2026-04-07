import 'package:flutter/material.dart';
import '../services/densezk_wasm_service.dart';
import '../models/densezk_models.dart';

class ProveScreen extends StatefulWidget {
  const ProveScreen({super.key});

  @override
  State<ProveScreen> createState() => _ProveScreenState();
}

class _ProveScreenState extends State<ProveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senderController = TextEditingController(text: '456');
  final _receiverController = TextEditingController(text: '789');
  final _weightController = TextEditingController(text: '1');
  final _graphRootController = TextEditingController(text: '0xabc123');
  final _thresholdController = TextEditingController(text: '1');

  bool _isLoading = false;
  String _result = '';
  ZKProof? _proof;

  Future<void> _prove() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = '';
      _proof = null;
    });

    try {
      final witness = await DenseZkWasmService.createWitness(
        sender: int.parse(_senderController.text),
        receiver: int.parse(_receiverController.text),
        weight: int.parse(_weightController.text),
      );

      final publicInputs = PublicInputs(
        graphRoot: _graphRootController.text,
        threshold: int.parse(_thresholdController.text),
      );

      final proof = await DenseZkWasmService.prove(
        witness: witness,
        publicInputs: publicInputs,
      );

      setState(() {
        _proof = proof;
        _result = 'Step 1: Witness generated\n'
            '  Commitment: ${witness.commitment}\n\n'
            'Step 2: Proof generated\n'
            '  Proof size: ${proof.proofBytes.length} bytes\n'
            '  Root commitment: ${proof.rootCommitment}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _senderController.dispose();
    _receiverController.dispose();
    _weightController.dispose();
    _graphRootController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step-by-Step Prove'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Two-Step Proof',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'First creates a witness with Poseidon commitment, then generates a Groth16 proof.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Graph Edge',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _senderController,
                label: 'Sender ID',
                hint: '456',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _receiverController,
                label: 'Receiver ID',
                hint: '789',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _weightController,
                label: 'Edge Weight',
                hint: '1',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Public Inputs',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _graphRootController,
                label: 'Graph Root',
                hint: '0xabc123',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _thresholdController,
                label: 'Threshold',
                hint: '1',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _prove,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.security),
                label: Text(_isLoading ? 'Proving...' : 'Generate Proof'),
              ),
              if (_result.isNotEmpty) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proof Result',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        SelectableText(
                          _result,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                              ),
                        ),
                        if (_proof != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          Text(
                            'Proof Bytes (hex):',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            _proof!.proofBytes
                                .map((b) => b.toRadixString(16).padLeft(2, '0'))
                                .join(''),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      keyboardType: TextInputType.number,
      validator: validator,
    );
  }
}
