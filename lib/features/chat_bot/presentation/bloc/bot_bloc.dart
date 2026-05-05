import 'dart:math';

import 'package:chat_bot/core/handler/api_error_handler.dart';
import 'package:chat_bot/features/chat_bot/domain/repository/chat_repository.dart';
import 'package:chat_bot/features/chat_bot/domain/repository/chatbot_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/message.dart';
import 'bot_event.dart';
import 'bot_state.dart';

class BotBloc extends Bloc<BotEvent, BotState> {
  final ChatRepository chatRepository;
  final ChatbotRepo chatbotRepo;

  final String userId;

  BotBloc({
    required this.chatRepository,
    required this.chatbotRepo,
    required this.userId,
  }) : super(const BotState()) {
    on<LoadMessagesEvent>(_loadMessages);
    on<SendMessageEvent>(_sendMessage);
    on<CreateConversationEvent>(_createConversation);
    on<SelectConversationEvent>(_selectConversation);
    on<LoadConversationsEvent>(_loadConversations);
  }

  final _random = Random();

  // ---------------- LOAD MESSAGES ----------------

  Future<void> _loadMessages(
    LoadMessagesEvent event,
    Emitter<BotState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final messages = await chatRepository.getMessages(
        userId: event.userId,
        conversationId: event.conversationId,
      );

      emit(
        state.copyWith(
          messages: messages,
          conversationId: event.conversationId,
          isLoading: false,
        ),
      );
    } catch (e) {
      final errorText = ApiErrorHandler.getMessage(e);

      final errorMessage = Message(
        id: const Uuid().v4(),
        text: "⚠️ $errorText",
        isUser: false,
        createdAt: DateTime.now(),
      );

      emit(
        state.copyWith(
          messages: [...state.messages, errorMessage],
          isLoading: false,
        ),
      );
    }
  }

  // ---------------- CREATE CONVERSATION ----------------

  Future<void> _createConversation(
    CreateConversationEvent event,
    Emitter<BotState> emit,
  ) async {
    try {
      final title = event.firstMessage.trim().isEmpty
          ? "New Chat"
          : _generateTitle(event.firstMessage);

      final conversationId = await chatRepository.createConversation(
        userId: event.userId,
        title: title,
      );

      final conversations = await chatRepository.getConversations(event.userId);

      emit(
        state.copyWith(
          conversationId: conversationId,
          messages: [],
          conversations: conversations,
        ),
      );

      if (event.firstMessage.trim().isNotEmpty) {
        add(
          SendMessageEvent(
            userId: event.userId,
            conversationId: conversationId,
            text: event.firstMessage,
          ),
        );
      }
    } catch (e) {
      final errorText = ApiErrorHandler.getMessage(e);

      final errorMessage = Message(
        id: const Uuid().v4(),
        text: "⚠️ $errorText",
        isUser: false,
        createdAt: DateTime.now(),
      );

      emit(state.copyWith(messages: [...state.messages, errorMessage]));
    }
  }

  // ---------------- SEND MESSAGE ----------------

  Future<void> _sendMessage(
    SendMessageEvent event,
    Emitter<BotState> emit,
  ) async {
    final now = DateTime.now();

    final isFirstMessage = state.messages.isEmpty;

    final userMessage = Message(
      id: const Uuid().v4(),
      text: event.text,
      isUser: true,
      createdAt: now,
    );

    final updatedMessages = [...state.messages, userMessage];

    emit(state.copyWith(messages: updatedMessages, isTyping: true));

    try {
      // 🔹 Save user message
      await chatRepository.sendMessage(
        userId: event.userId,
        conversationId: event.conversationId,
        message: userMessage,
      );

      // 🔥 Update title (first message only)
      if (isFirstMessage) {
        final newTitle = _generateTitle(event.text);

        await chatRepository.updateConversationTitle(
          userId: event.userId,
          conversationId: event.conversationId,
          title: newTitle,
        );

        final conversations = await chatRepository.getConversations(
          event.userId,
        );

        emit(state.copyWith(conversations: conversations));
      }

      // 🔹 Send history to API
      final history = [...state.messages, userMessage];

      final response = await chatbotRepo.sendMessage(history: history);

      // 🔹 Create empty bot message
      Message botMessage = Message(
        id: const Uuid().v4(),
        text: "",
        isUser: false,
        createdAt: DateTime.now(),
      );

      final tempList = [...updatedMessages, botMessage];

      emit(state.copyWith(messages: tempList));

      // 🔥 ChatGPT-like typing
      String current = "";

      for (int i = 0; i < response.length; i++) {
        final char = response[i];
        current += char;

        botMessage = botMessage.copyWith(text: current);
        tempList[tempList.length - 1] = botMessage;

        emit(state.copyWith(messages: List.from(tempList)));

        await Future.delayed(_typingDelay(char));
      }

      // 🔹 Save bot message
      await chatRepository.sendMessage(
        userId: event.userId,
        conversationId: event.conversationId,
        message: botMessage,
      );

      emit(state.copyWith(messages: tempList, isTyping: false));
    } catch (e) {
      final errorText = ApiErrorHandler.getMessage(e);

      final errorMessage = Message(
        id: const Uuid().v4(),
        text: "⚠️ $errorText\n\nPlease try again.",
        isUser: false,
        createdAt: DateTime.now(),
      );

      final updated = [...state.messages, errorMessage];

      // 🔥 Save error message (optional but good)
      await chatRepository.sendMessage(
        userId: event.userId,
        conversationId: event.conversationId,
        message: errorMessage,
      );

      emit(state.copyWith(messages: updated, isTyping: false));
    }
  }

  // ---------------- SELECT CONVERSATION ----------------

  Future<void> _selectConversation(
    SelectConversationEvent event,
    Emitter<BotState> emit,
  ) async {
    emit(state.copyWith(messages: []));

    add(
      LoadMessagesEvent(userId: userId, conversationId: event.conversationId),
    );
  }

  // ---------------- LOAD CONVERSATIONS ----------------

  Future<void> _loadConversations(
    LoadConversationsEvent event,
    Emitter<BotState> emit,
  ) async {
    try {
      final conversations = await chatRepository.getConversations(event.userId);

      emit(state.copyWith(conversations: conversations));
    } catch (e) {
      final errorText = ApiErrorHandler.getMessage(e);

      final errorMessage = Message(
        id: const Uuid().v4(),
        text: "⚠️ $errorText",
        isUser: false,
        createdAt: DateTime.now(),
      );

      emit(state.copyWith(messages: [...state.messages, errorMessage]));
    }
  }

  // ---------------- HELPERS ----------------

  Duration _typingDelay(String char) {
    int base;

    if (char == ' ') {
      base = 8;
    } else if ('.!?'.contains(char)) {
      base = 90;
    } else if (char == '\n') {
      base = 120;
    } else {
      base = 18;
    }

    return Duration(milliseconds: base + _random.nextInt(10));
  }

  String _generateTitle(String text) {
    return text.replaceAll("\n", " ").trim().split(" ").take(5).join(" ");
  }
}
