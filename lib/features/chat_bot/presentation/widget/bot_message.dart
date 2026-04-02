import 'package:chat_bot/features/chat_bot/data/model/message.dart';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class BotMessage extends StatelessWidget {
  const BotMessage({super.key, required this.msg});

  final Message msg;

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
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.white),
                bodyLarge: TextStyle(color: Colors.white),
              ),
            ),
            child: GptMarkdown(
              msg.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
