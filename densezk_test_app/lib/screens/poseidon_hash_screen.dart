import 'package:flutter/material.dart';
import '../services/densezk_wasm_service.dart';

class PoseidonHashScreen extends StatefulWidget {
  const PoseidonHashScreen({super.key});

  @override
  State<PoseidonHashScreen> createState() => _PoseidonHashScreenState();
}

class _PoseidonHashScreenState extends State<PoseidonHashScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senderController = TextEditingController(text: '456');
  final _receiverController = TextEditingController(text: '789');
  final _weightController = TextEditingController(text: '1');

  bool _isLoading = false;
  String _hashResult = '';

  Future<void> _hashEdge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hashResult = '';
    });

    try {
      final hashResult = await DenseZkWasmService.poseidonHash(
        sender: int.parse(_senderController.text),
        receiver: int.parse(_receiverController.text),
        weight: int.parse(_weightController.text),
      );

      setState(() {
        _hashResult = 'Poseidon hash computed successfully!\n\n'
            'Input: sender=${_senderController.text}, '
            'receiver=${_receiverController.text}, '
            'weight=${_weightController.text}\n\n'
            'Hash: $hashResult';
      });
    } catch (e) {
      setState(() {
        _hashResult = 'Error: $e';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poseidon Hash'),
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
                        'Poseidon Hash Function',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hashes three u64 values as BN254 field elements using Circom-compatible Poseidon (3-input, x^5 S-box).',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _hashEdge,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.functions),
                label: Text(_isLoading ? 'Hashing...' : 'Compute Hash'),
              ),
              if (_hashResult.isNotEmpty) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hash Result',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        SelectableText(
                          _hashResult,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                              ),
                        ),
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
