import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_bloc.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_event.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_state.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/app_drawer.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/user_message.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/empty_state.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/input_bar.dart';
import 'package:chat_bot/features/chat_bot/presentation/widget/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BotScreen extends StatefulWidget {
  final String userId;

  const BotScreen({super.key, required this.userId});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> with WidgetsBindingObserver {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    context.read<BotBloc>().add(LoadConversationsEvent(widget.userId));
    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      _isUserScrolling = direction != ScrollDirection.idle;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    controller.dispose();
    focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    if (_isUserScrolling) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;

      _scrollController.jumpTo(position.maxScrollExtent);
    });
  }

  void _sendMessage(BuildContext context, String text, List<String> images) {
    final bloc = context.read<BotBloc>();
    final state = bloc.state;

    if (state.conversationId == null) {
      bloc.add(
        CreateConversationEvent(
          userId: widget.userId,
          firstMessage: text,
          imagePaths: images,
        ),
      );
    } else {
      bloc.add(
        SendMessageEvent(
          userId: widget.userId,
          conversationId: state.conversationId!,
          text: text,
          imagePaths: images,
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
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<BotBloc, BotState>(
              builder: (context, state) {
                final messages = state.messages;
                final isTyping = state.isTyping;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Expanded(
                          child:
                              messages.isEmpty && !isTyping && !state.isLoading
                              ? EmptyState(
                                  onExampleTap: (text) {
                                    _sendMessage(context, text, []);
                                  },
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  cacheExtent: 300,
                                  itemExtent: null,
                                  addAutomaticKeepAlives: false,
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  addSemanticIndexes: false,
                                  addRepaintBoundaries: true,
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

                                    return RepaintBoundary(
                                      child: UserMessage(msg: msg),
                                    );
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
