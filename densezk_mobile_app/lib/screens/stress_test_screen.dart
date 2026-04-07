import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/densezk_provider.dart';
import '../widgets/result_card.dart';

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

  Future<void> _runStressTest() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<DenseZkProvider>().runStressTest(
          iterations: int.parse(_iterationsController.text),
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
        title: const Text('Stress Test'),
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
                            'Performance Benchmark',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Run multiple proof generations and measure performance metrics.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
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
                  ),
                  const SizedBox(height: 12),
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
                    onPressed: provider.isLoading ? null : _runStressTest,
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.speed),
                    label: Text(provider.isLoading ? 'Running...' : 'Run Stress Test'),
                  ),
                  if (provider.error.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ResultCard(
                      title: 'Error',
                      content: provider.error,
                      isError: true,
                    ),
                  ],
                  if (provider.stressResults != null) ...[
                    const SizedBox(height: 16),
                    _buildStressResults(provider.stressResults!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStressResults(Map<String, dynamic> results) {
    final successCount = results['success_count'] as int;
    final failCount = results['fail_count'] as int;
    final successRate = results['success_rate'] as String;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stress Test Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildResultRow('Iterations', results['iterations'].toString()),
            _buildResultRow('Success', '$successCount'),
            _buildResultRow('Failed', '$failCount'),
            _buildResultRow('Success Rate', successRate),
            if (results['total_time_ms'] != null) ...[
              const Divider(),
              _buildResultRow('Total Time', '${results['total_time_ms']} ms'),
              _buildResultRow('Avg Time', '${results['avg_time_ms']} ms'),
              _buildResultRow('Min Time', '${results['min_time_ms']} ms'),
              _buildResultRow('Max Time', '${results['max_time_ms']} ms'),
            ],
            if ((results['proof_sizes'] as List).isNotEmpty) ...[
              const Divider(),
              _buildResultRow(
                'Proof Size',
                '${(results['proof_sizes'] as List<int>).first} bytes',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
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
