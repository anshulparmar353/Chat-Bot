import 'package:chat_bot/features/chat_bot/presentation/widget/dot_animation.dart';
import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(left: 8, right: 60, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DotAnimation(delay: 0),
          
              SizedBox(width: 4),
          
              DotAnimation(delay: 150),
          
              SizedBox(width: 4),
          
              DotAnimation(delay: 300),
            ],
          ),
        ),
      ),
    );
  }
}
