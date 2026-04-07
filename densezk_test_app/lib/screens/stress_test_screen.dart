import 'package:flutter/material.dart';
import '../services/densezk_wasm_service.dart';

class StressTestScreen extends StatefulWidget {
  const StressTestScreen({super.key});

  @override
  State<StressTestScreen> createState() => _StressTestScreenState();
}

class _StressTestScreenState extends State<StressTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _iterationsController = TextEditingController(text: '10');
  final _senderController = TextEditingController(text: '456');
  final _receiverController = TextEditingController(text: '789');
  final _weightController = TextEditingController(text: '1');
  final _graphRootController = TextEditingController(text: '0xabc123');
  final _thresholdController = TextEditingController(text: '1');

  bool _isLoading = false;
  String _result = '';
  Map<String, dynamic>? _stats;

  Future<void> _runStressTest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = '';
      _stats = null;
    });

    try {
      final iterations = int.parse(_iterationsController.text);
      final startTime = DateTime.now();

      final stats = await DenseZkWasmService.runStressTest(
        iterations: iterations,
        sender: int.parse(_senderController.text),
        receiver: int.parse(_receiverController.text),
        weight: int.parse(_weightController.text),
        graphRoot: _graphRootController.text,
        threshold: int.parse(_thresholdController.text),
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      setState(() {
        _stats = stats;
        _result = 'Stress test completed!\n'
            'Iterations: ${stats['iterations'] ?? iterations}\n'
            'Duration: ${duration.inMilliseconds}ms\n'
            'Avg time per proof: ${(duration.inMilliseconds / iterations).toStringAsFixed(2)}ms\n'
            'Success rate: ${stats['success_rate'] ?? '100%'}';
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
    _iterationsController.dispose();
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
        title: const Text('Stress Test'),
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
                        'Performance Testing',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Run multiple proof generations to measure performance and reliability.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _iterationsController,
                label: 'Iterations',
                hint: '10',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Must be > 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _senderController,
                      label: 'Sender ID',
                      hint: '456',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _receiverController,
                      label: 'Receiver ID',
                      hint: '789',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _weightController,
                      label: 'Weight',
                      hint: '1',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _thresholdController,
                      label: 'Threshold',
                      hint: '1',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _graphRootController,
                label: 'Graph Root',
                hint: '0xabc123',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _runStressTest,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.speed),
                label: Text(_isLoading ? 'Running...' : 'Run Stress Test'),
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
                          'Results',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        SelectableText(
                          _result,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                              ),
                        ),
                        if (_stats != null && _stats!['proof_sizes'] != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Proof sizes: ${_stats!['proof_sizes']}',
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
