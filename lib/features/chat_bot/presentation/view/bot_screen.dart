import 'package:chat_bot/features/chat_bot/data/model/message.dart';
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
  const BotScreen({super.key});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  List<Message> _cachedMessages = [];

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const AppDrawer(),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text("ChatBot", style: TextStyle(color: Colors.white)),
        leading: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.short_text_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<BotBloc, BotState>(
              listener: (context, state) {
                if (state is BotErrorState) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                }
              },

              builder: (context, state) {
                final bool isTyping =
                    state is BotTypingState || state is BotStreamingState;

                if (state is BotMessageState) {
                  _cachedMessages = state.messages;
                } else if (state is BotTypingState) {
                  _cachedMessages = state.messages;
                } else if (state is BotStreamingState) {
                  _cachedMessages = state.messages;
                } else if (state is BotErrorState) {
                  _cachedMessages = state.messages;
                }
                final messages = _cachedMessages;

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Expanded(
                          child: messages.isEmpty && !isTyping
                              ? EmptyState(
                                  onExampleTap: (text) {
                                    controller.text = text;
                                    focusNode.requestFocus();

                                    context.read<BotBloc>().add(
                                      SendMessageEvent(message: text),
                                    );
                                  },
                                )
                              : ListView.builder(
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

          InputBar(controller: controller, focusNode: focusNode),
        ],
      ),
    );
  }
}
