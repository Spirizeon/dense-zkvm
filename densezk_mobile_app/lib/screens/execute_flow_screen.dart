import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/densezk_provider.dart';
import '../widgets/result_card.dart';

class ExecuteFlowScreen extends StatefulWidget {
  const ExecuteFlowScreen({super.key});

  @override
  State<ExecuteFlowScreen> createState() => _ExecuteFlowScreenState();
}

class _ExecuteFlowScreenState extends State<ExecuteFlowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senderController = TextEditingController(text: '456');
  final _receiverController = TextEditingController(text: '789');
  final _weightController = TextEditingController(text: '1');
  final _graphRootController = TextEditingController(text: '0xabc123');
  final _thresholdController = TextEditingController(text: '1');

  @override
  void dispose() {
    _senderController.dispose();
    _receiverController.dispose();
    _weightController.dispose();
    _graphRootController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _execute() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<DenseZkProvider>().executeFlow(
          senderId: int.parse(_senderController.text),
          receiverId: int.parse(_receiverController.text),
          weight: int.parse(_weightController.text),
          graphRoot: _graphRootController.text,
          threshold: int.parse(_thresholdController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Execute Flow'),
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
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _graphRootController,
                    label: 'Graph Root',
                    hint: '0xabc123',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _thresholdController,
                    label: 'Threshold',
                    hint: '1',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : _execute,
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.flash_on),
                    label: Text(provider.isLoading ? 'Generating...' : 'Execute ZK Flow'),
                  ),
                  if (provider.error.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ResultCard(
                      title: 'Error',
                      content: provider.error,
                      isError: true,
                    ),
                  ],
                  if (provider.lastProof != null) ...[
                    const SizedBox(height: 16),
                    ResultCard(
                      title: 'Proof Result',
                      content:
                          'Proof size: ${provider.lastProof!.proofBytes.length} bytes\n'
                          'Root commitment: ${provider.lastProof!.rootCommitment}',
                      hexData: provider.lastProof!.proofHex,
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
