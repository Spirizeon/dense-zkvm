import 'package:flutter/material.dart';
import 'witness_screen.dart';
import 'execute_flow_screen.dart';
import 'stress_test_screen.dart';
import 'prove_screen.dart';
import 'poseidon_hash_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DenseZK Test App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FeatureCard(
            icon: Icons.flash_on,
            iconColor: Colors.orange,
            title: 'Execute Flow',
            description: 'One-shot ZK proof generation with all inputs',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExecuteFlowScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.visibility,
            iconColor: Colors.blue,
            title: 'Create Witness',
            description: 'Generate Poseidon commitment for a graph edge',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WitnessScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.speed,
            iconColor: Colors.red,
            title: 'Stress Test',
            description: 'Run multiple proof generations and measure performance',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StressTestScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.security,
            iconColor: Colors.green,
            title: 'Step-by-Step Prove',
            description: 'Create witness then prove separately',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProveScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.functions,
            iconColor: Colors.purple,
            title: 'Poseidon Hash',
            description: 'Hash graph edge with Poseidon over BN254',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PoseidonHashScreen()),
              );
            },
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
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
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
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
