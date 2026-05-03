import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.onExampleTap});

  final Function(String)? onExampleTap;

  @override
  Widget build(BuildContext context) {
    final examples = [
      "📱 Build a Flutter app idea",
      "🧠 Design clean architecture",
      "⚡ Optimize app performance",
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "How can I help you today?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          const Text(
            "Ask anything. Get instant answers, ideas, or help.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          ...examples.map((e) => _buildExample(e)),
        ],
      ),
    );
  }

  Widget _buildExample(String text) {
    return GestureDetector(
      onTap: () => onExampleTap?.call(text),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
