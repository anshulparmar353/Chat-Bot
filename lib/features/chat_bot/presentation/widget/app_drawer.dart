import 'package:chat_bot/features/chat_bot/domain/entities/conversation.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_bloc.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_event.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppDrawer extends StatelessWidget {
  final String userId;

  const AppDrawer({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,

      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.asset("assets/chatbot.png", width: 28, height: 28),
                  const SizedBox(width: 10),
                  const Text(
                    "ChatBot",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white24),

            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text(
                "New Chat",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);

                context.read<BotBloc>().add(
                  CreateConversationEvent(
                    userId: userId,
                    firstMessage: "",
                  ),
                );
              },
            ),

            Divider(color: Colors.white24),

            Expanded(
              child: BlocBuilder<BotBloc, BotState>(
                builder: (context, state) {
                  final conversations = state.conversations;

                  if (conversations.isEmpty) {
                    return const Center(
                      child: Text(
                        "No chats yet",
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final Conversation conv = conversations[index];

                      final isSelected = conv.id == state.conversationId;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.white10,
                        leading: const Icon(Icons.chat, color: Colors.white70),
                        title: Text(
                          conv.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context);

                          context.read<BotBloc>().add(
                            SelectConversationEvent(conv.id),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            Divider(color: Colors.white24),

            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text(
                "Settings",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
