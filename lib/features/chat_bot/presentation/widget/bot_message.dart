import 'package:chat_bot/features/chat_bot/data/model/message.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/code_block_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class BotMessage extends StatelessWidget {
  const BotMessage({super.key, required this.msg});

  final Message msg;

  String formatText(String text) {
    text = text.replaceAllMapped(
      RegExp(r'^\d+\.\s(.+)', multiLine: true),
      (m) => '## ${m.group(1)}',
    );

    text = text.replaceAll('! ?', '!?');

    return text;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 150),
      tween: Tween(begin: 0.95, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.black,

        child: MarkdownBody(
          data: formatText(msg.text),

          selectable: true,

          builders: {
            'pre': CodeBlockBuilder(), 
          },
          styleSheet: MarkdownStyleSheet(
            h2: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),

            h3: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),

            p: const TextStyle(color: Colors.white, fontSize: 14, height: 1.7),

            listBullet: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
