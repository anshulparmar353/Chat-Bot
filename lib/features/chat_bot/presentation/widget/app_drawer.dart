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
                  CreateConversationEvent(userId: userId, firstMessage: ""),
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

                        trailing: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white54,
                          ),

                          color: Colors.grey[900],

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),

                          onSelected: (value) {
                            if (value == "rename") {
                              _showRenameDialog(context, conv);
                            }

                            if (value == "delete") {
                              _showDeleteDialog(context, conv);
                            }
                          },

                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: "rename",
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.white,
                                  ),

                                  SizedBox(width: 10),

                                  Text(
                                    "Rename",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),

                            const PopupMenuItem(
                              value: "delete",
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),

                                  SizedBox(width: 10),

                                  Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  void _showRenameDialog(BuildContext context, Conversation conversation) {
    final controller = TextEditingController(text: conversation.title);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],

          title: const Text(
            "Rename Chat",
            style: TextStyle(color: Colors.white),
          ),

          content: TextField(
            controller: controller,
            autofocus: true,

            style: const TextStyle(color: Colors.white),

            decoration: InputDecoration(
              hintText: "Enter new title",

              hintStyle: const TextStyle(color: Colors.white54),

              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),

              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () {
                final newTitle = controller.text.trim();

                if (newTitle.isEmpty) return;

                context.read<BotBloc>().add(
                  RenameConversationEvent(
                    userId: userId,
                    conversationId: conversation.id,
                    newTitle: newTitle,
                  ),
                );

                Navigator.pop(context);
              },

              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Conversation conversation) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],

          title: const Text(
            "Delete Chat",
            style: TextStyle(color: Colors.white),
          ),

          content: const Text(
            "Are you sure you want to delete this chat?",
            style: TextStyle(color: Colors.white70),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);

                context.read<BotBloc>().add(
                  DeleteConversationEvent(
                    userId: userId,
                    conversationId: conversation.id,
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Chat deleted"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },

              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
