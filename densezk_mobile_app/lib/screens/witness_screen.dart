import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/densezk_provider.dart';
import '../widgets/result_card.dart';

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

  @override
  void dispose() {
    _senderController.dispose();
    _receiverController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _createWitness() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<DenseZkProvider>().createWitness(
          senderId: int.parse(_senderController.text),
          receiverId: int.parse(_receiverController.text),
          weight: int.parse(_weightController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Witness'),
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
                    onPressed: provider.isLoading ? null : _createWitness,
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.visibility),
                    label: Text(provider.isLoading ? 'Generating...' : 'Create Witness'),
                  ),
                  if (provider.error.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ResultCard(
                      title: 'Error',
                      content: provider.error,
                      isError: true,
                    ),
                  ],
                  if (provider.lastWitness != null) ...[
                    const SizedBox(height: 16),
                    ResultCard(
                      title: 'Witness Result',
                      content:
                          'Sender ID: ${provider.lastWitness!.edge.senderId}\n'
                          'Receiver ID: ${provider.lastWitness!.edge.receiverId}\n'
                          'Weight: ${provider.lastWitness!.edge.weight}\n\n'
                          'Poseidon Commitment:\n${provider.lastWitness!.commitment}',
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
