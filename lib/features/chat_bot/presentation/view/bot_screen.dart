import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_bloc.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_event.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_state.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/app_drawer.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/user_message.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/empty_state.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/input_bar.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({super.key, required this.userId});

  final String userId;

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    context.read<BotBloc>().add(LoadConversationsEvent(widget.userId));
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext context, String text, List<String> images) {
    final bloc = context.read<BotBloc>();
    final state = bloc.state;

    if (state.conversationId == null) {
      bloc.add(
        CreateConversationEvent(userId: widget.userId, firstMessage: text),
      );
    } else {
      bloc.add(
        SendMessageEvent(
          userId: widget.userId,
          conversationId: state.conversationId!,
          text: text,
        ),
      );
    }
    controller.clear();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      drawer: AppDrawer(userId: widget.userId),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text("ChatBot", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<BotBloc, BotState>(
              builder: (context, state) {
                final messages = state.messages;
                final isTyping = state.isTyping;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Expanded(
                          child: messages.isEmpty && !isTyping
                              ? EmptyState(
                                  onExampleTap: (text) {
                                    _sendMessage(context, text, []);
                                  },
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  itemCount:
                                      messages.length + (isTyping ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= messages.length) {
                                      return const TypingIndicator();
                                    }

                                    final msg = messages[index];
                                    return UserMessage(msg: msg);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          InputBar(
            controller: controller,
            focusNode: focusNode,
            onSend: (text, images) => _sendMessage(context, text, images),
          ),
        ],
      ),
    );
  }
}
