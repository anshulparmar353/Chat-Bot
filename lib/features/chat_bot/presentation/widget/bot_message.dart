import 'package:chat_bot/features/chat_bot/domain/entities/message.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/code_block_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class BotMessage extends StatefulWidget {
  const BotMessage({super.key, required this.msg});

  final Message msg;

  @override
  State<BotMessage> createState() => _BotMessageState();
}

class _BotMessageState extends State<BotMessage> {
  bool useMarkdown = false; 

  @override
  void didUpdateWidget(covariant BotMessage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final formatted = _formatText(widget.msg.text);

    if (!useMarkdown && _isMarkdownStable(formatted)) {
      useMarkdown = true;
    }
  }

  String _formatText(String text) {
    text = text.replaceAllMapped(
      RegExp(r'^(#{1,6})(\S)', multiLine: true),
      (m) => '${m.group(1)} ${m.group(2)}',
    );

    return text.replaceAll('! ?', '!?');
  }

  bool _isMarkdownStable(String text) {
    final t = text.trim();

    if (t.isEmpty) return false;

    if (t.contains('```') && t.split('```').length.isOdd) return false;

    final lastLine = t.split('\n').last;
    if (RegExp(r'^(#{1,6})\s*$').hasMatch(lastLine)) return false;

    if (RegExp(r'(\*|_)$').hasMatch(t)) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _formatText(widget.msg.text);

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
        child: _buildMessage(formatted),
      ),
    );
  }

  Widget _buildMessage(String formatted) {
    if (!useMarkdown) {
      return Text(
        formatted,
        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.7),
      );
    }

    try {
      return MarkdownBody(
        data: formatted,
        selectable: true,
        builders: {'pre': CodeBlockBuilder()},
        styleSheet: _styleSheet(),
      );
    } catch (_) {
      return Text(formatted, style: const TextStyle(color: Colors.white));
    }
  }

  MarkdownStyleSheet _styleSheet() {
    return MarkdownStyleSheet(
      h1: const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      h2: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      h3: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      p: const TextStyle(color: Colors.white, fontSize: 15, height: 1.8),
      strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      em: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
      listBullet: const TextStyle(color: Colors.white),
      listIndent: 24,
      blockSpacing: 10,
    );
  }
}
