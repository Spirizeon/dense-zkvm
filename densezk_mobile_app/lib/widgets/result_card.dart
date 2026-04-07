import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String content;
  final String? hexData;
  final bool isError;

  const ResultCard({
    super.key,
    required this.title,
    required this.content,
    this.hexData,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isError ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyToClipboard(context),
                  tooltip: 'Copy',
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              content,
              style: TextStyle(
                fontFamily: 'monospace',
                color: isError ? Colors.red.shade700 : null,
              ),
            ),
            if (hexData != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const Text(
                'Proof Bytes (hex):',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              SelectableText(
                hexData!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final text = hexData != null ? '$content\n\n$hexData' : content;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
