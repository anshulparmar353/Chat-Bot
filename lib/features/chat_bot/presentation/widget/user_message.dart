import 'dart:io';

import 'package:chat_bot/features/chat_bot/data/model/message.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/bot_message.dart';
import 'package:flutter/material.dart';

class UserMessage extends StatelessWidget {
  const UserMessage({super.key, required this.msg});

  final Message msg;

  @override
  Widget build(BuildContext context) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (msg.imagePaths != null && msg.imagePaths!.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: msg.imagePaths!.map((path) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(path),
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),

              if (msg.imagePaths != null &&
                  msg.imagePaths!.isNotEmpty &&
                  msg.text.isNotEmpty)
                const SizedBox(height: 8),

              if (msg.text.isNotEmpty)
                Text(msg.text, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    } else {
      return BotMessage(msg: msg);
    }
  }
}
