import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/densezk_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DenseZK'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Consumer<DenseZkProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ConnectionBanner(isConnected: provider.isConnected),
              const SizedBox(height: 20),
              Text(
                'Features',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.flash_on,
                iconColor: Colors.orange,
                title: 'Execute Flow',
                description: 'One-shot ZK proof generation',
                onTap: () => Navigator.pushNamed(context, '/execute'),
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.visibility,
                iconColor: Colors.blue,
                title: 'Create Witness',
                description: 'Generate Poseidon commitment',
                onTap: () => Navigator.pushNamed(context, '/witness'),
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.security,
                iconColor: Colors.green,
                title: 'Step-by-Step Prove',
                description: 'Witness then prove separately',
                onTap: () => Navigator.pushNamed(context, '/prove'),
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.functions,
                iconColor: Colors.purple,
                title: 'Poseidon Hash',
                description: 'Hash graph edge with Poseidon',
                onTap: () => Navigator.pushNamed(context, '/poseidon'),
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.speed,
                iconColor: Colors.red,
                title: 'Stress Test',
                description: 'Benchmark proof generation',
                onTap: () => Navigator.pushNamed(context, '/stress'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final provider = context.read<DenseZkProvider>();
    final controller = TextEditingController(text: provider.serverUrl);
    bool isTesting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Server Settings'),
          content: TextField(
            controller: controller,
            enabled: !isTesting,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Server URL',
              hintText: 'http://10.0.2.2:8080',
            ),
          ),
          actions: [
            TextButton(
              onPressed: isTesting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            OutlinedButton(
              onPressed: isTesting
                  ? null
                  : () async {
                      if (controller.text.isEmpty) return;
                      setState(() => isTesting = true);
                      provider.setServerUrl(controller.text);
                      final connected = await provider.checkConnection();
                      setState(() => isTesting = false);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            connected
                                ? 'Connection successful!'
                                : 'Connection failed: ${provider.error}',
                          ),
                          backgroundColor:
                              connected ? Colors.green : Colors.red,
                        ),
                      );
                    },
              child: isTesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test'),
            ),
            ElevatedButton(
              onPressed: isTesting
                  ? null
                  : () {
                      if (controller.text.isNotEmpty) {
                        provider.setServerUrl(controller.text);
                      }
                      Navigator.pop(ctx);
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  final bool isConnected;
  const _ConnectionBanner({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.error_outline,
            color: isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isConnected ? 'Connected to server' : 'Disconnected from server',
              style: TextStyle(
                color: isConnected ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!isConnected)
            TextButton(
              onPressed: () => context.read<DenseZkProvider>().checkConnection(),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
