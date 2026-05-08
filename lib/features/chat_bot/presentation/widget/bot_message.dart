import 'package:chat_bot/features/chat_bot/domain/entities/message.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/code_block_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class BotMessage extends StatelessWidget {
  const BotMessage({super.key, required this.msg});

  final Message msg;

  String _formatText(String text) {
    text = text.replaceAllMapped(
      RegExp(r'^(#{1,6})(\S)', multiLine: true),
      (m) => '${m.group(1)} ${m.group(2)}',
    );

    return text.replaceAll('! ?', '!?');
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _formatText(msg.text);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.black,
      child: _buildMessage(formatted),
    );
  }

  Widget _buildMessage(String formatted) {

    if (msg.isStreaming) {
      return Text(
        _plainText(formatted),
        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.55),
      );
    }

    return MarkdownBody(
      data: formatted,
      selectable: true,
      shrinkWrap: true,
      softLineBreak: true,
      builders: {'pre': CodeBlockBuilder()},
      styleSheet: _styleSheet(),
    );
  }

  MarkdownStyleSheet _styleSheet() {
    return MarkdownStyleSheet(
      h1: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),

      h2: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),

      h3: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),

      p: const TextStyle(color: Colors.white, fontSize: 15, height: 1.45),

      strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),

      em: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),

      listBullet: const TextStyle(color: Colors.white, height: 1.35),

      blockSpacing: 5,
      listIndent: 20,
    );
  }

  String _plainText(String text) {
    return text
        .replaceAll(RegExp(r'#{1,6}\s*'), '')
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('---', '')
        .replaceAll('`', '');
  }
}
