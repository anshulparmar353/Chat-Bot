import 'package:chat_bot/features/chat_bot/data/model/message.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_bloc.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_state.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/app_drawer.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/chat_bubble.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/empty_state.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/input_bar.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool _isUserInteracting = false;

  void _scrollDown({bool force = false}) {
    if (!scrollController.hasClients) return;

    if (!force && _isUserInteracting) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
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
                if (state is BotMessageState ||
                    state is BotStreamingState ||
                    state is BotTypingState) {
                  _scrollDown();
                }

                if (state is BotErrorState) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                }
              },

              builder: (context, state) {
                List<Message> messages = [];
                bool isTyping = false;

                if (state is BotMessageState) {
                  messages = state.messages;
                } else if (state is BotTypingState) {
                  messages = state.messages;
                  isTyping = true;
                } else if (state is BotStreamingState) {
                  messages = state.messages;
                } else if (state is BotErrorState) {
                  messages = state.messages;
                }

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Expanded(
                          child: messages.isEmpty
                              ? EmptyState()
                              : NotificationListener<UserScrollNotification>(
                                  onNotification: (notification) {
                                    if (notification.direction ==
                                            ScrollDirection.reverse ||
                                        notification.direction ==
                                            ScrollDirection.forward) {
                                      _isUserInteracting = true;
                                    }

                                    if (notification.direction ==
                                        ScrollDirection.idle) {
                                      _isUserInteracting = false;
                                    }

                                    return false;
                                  },
                                  child: ListView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    itemCount:
                                        messages.length + (isTyping ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index >= messages.length) {
                                        return TypingIndicator();
                                      }

                                      final msg = messages[index];
                                      return ChatBubble(msg: msg);
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          InputBar(),
        ],
      ),
    );
  }
}
