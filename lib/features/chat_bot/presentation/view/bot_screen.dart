import 'package:chat_bot/features/chat_bot/data/model/message.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_bloc.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_state.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/app_drawer.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/chat_bubble.dart';
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
  final ScrollController scrollController = ScrollController();

  List<Message> _cachedMessages = [];

  bool _isNearBottom() {
    if (!scrollController.hasClients) return true;

    final max = scrollController.position.maxScrollExtent;
    final current = scrollController.position.pixels;

    return (max - current) < 200;
  }

  void _scrollDown({bool force = false, bool smooth = true}) {
    if (!scrollController.hasClients) return;

    if (!force && !_isNearBottom()) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (smooth) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
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
                if (state is BotStreamingState) {
                  _scrollDown(smooth: false);
                } else if (state is BotTypingState ||
                    state is BotMessageState) {
                  _scrollDown(smooth: true);
                }

                if (state is BotErrorState) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                }
              },

              builder: (context, state) {
                bool isTyping =
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

                List<Message> messages = _cachedMessages;

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Expanded(
                          child: messages.isEmpty && state is! BotTypingState
                              ? EmptyState()
                              : ListView.builder(
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
