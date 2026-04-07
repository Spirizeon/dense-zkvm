import 'package:flutter/material.dart';
import '../services/densezk_wasm_service.dart';
import '../models/densezk_models.dart';

class WitnessScreen extends StatefulWidget {
  const WitnessScreen({super.key});

  @override
  State<WitnessScreen> createState() => _WitnessScreenState();
}

class _WitnessScreenState extends State<WitnessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senderController = TextEditingController(text: '456');
  final _receiverController = TextEditingController(text: '789');
  final _weightController = TextEditingController(text: '1');

  bool _isLoading = false;
  String _result = '';
  ClientWitness? _witness;

  Future<void> _createWitness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = '';
      _witness = null;
    });

    try {
      final witness = await DenseZkWasmService.createWitness(
        sender: int.parse(_senderController.text),
        receiver: int.parse(_receiverController.text),
        weight: int.parse(_weightController.text),
      );

      setState(() {
        _witness = witness;
        _result = 'Witness generated successfully!\n'
            'Commitment: ${witness.commitment}\n'
            'Edge: sender=${witness.edge.senderId}, '
            'receiver=${witness.edge.receiverId}, '
            'weight=${witness.edge.weight}';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Witness'),
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
                        'Graph Edge Input',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the sender ID, receiver ID, and edge weight to generate a Poseidon commitment.',
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
                onPressed: _isLoading ? null : _createWitness,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.visibility),
                label: Text(_isLoading ? 'Generating...' : 'Create Witness'),
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
                          'Witness Result',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        if (_witness != null) ...[
                          _buildResultRow('Sender ID', _witness!.edge.senderId.toString()),
                          _buildResultRow('Receiver ID', _witness!.edge.receiverId.toString()),
                          _buildResultRow('Weight', _witness!.edge.weight.toString()),
                          const Divider(height: 24),
                          Text(
                            'Poseidon Commitment',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            _witness!.commitment,
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

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
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
