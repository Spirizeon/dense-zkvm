import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/densezk_provider.dart';
import '../widgets/result_card.dart';

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
  String? _hashResult;

  @override
  void dispose() {
    _senderController.dispose();
    _receiverController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _hash() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await context.read<DenseZkProvider>().poseidonHash(
          senderId: int.parse(_senderController.text),
          receiverId: int.parse(_receiverController.text),
          weight: int.parse(_weightController.text),
        );
    if (result != null) {
      setState(() => _hashResult = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poseidon Hash'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<DenseZkProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Poseidon Hash over BN254',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Hashes a graph edge using Poseidon with x^5 S-box over the BN254 scalar field.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
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
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _receiverController,
                    label: 'Receiver ID',
                    hint: '789',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _weightController,
                    label: 'Edge Weight',
                    hint: '1',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : _hash,
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.functions),
                    label: Text(provider.isLoading ? 'Hashing...' : 'Compute Hash'),
                  ),
                  if (provider.error.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ResultCard(
                      title: 'Error',
                      content: provider.error,
                      isError: true,
                    ),
                  ],
                  if (_hashResult != null) ...[
                    const SizedBox(height: 16),
                    ResultCard(
                      title: 'Hash Result',
                      content: _hashResult!,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
      keyboardType: TextInputType.number,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }
}
