import 'package:chat_bot/core/handler/api_error_handler.dart';
import 'package:chat_bot/core/helper/list_extension.dart';
import 'package:chat_bot/features/chat_bot/domain/repository/chat_repository.dart';
import 'package:chat_bot/features/chat_bot/domain/repository/chatbot_repo.dart';
import 'package:flutter/material.dart';
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
    on<DeleteConversationEvent>(_deleteConversation);
    on<RenameConversationEvent>(_renameConversation);
  }

  int _streamSession = 0;
  bool _isSending = false;

  Future<void> _loadMessages(
    LoadMessagesEvent event,
    Emitter<BotState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, conversationId: event.conversationId));

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
      _emitErrorAsMessage(e, emit);
    }
  }

  Future<void> _createConversation(
    CreateConversationEvent event,
    Emitter<BotState> emit,
  ) async {
    try {
      _streamSession++;

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
          isTyping: false,
        ),
      );

      final hasText = event.firstMessage.trim().isNotEmpty;

      final hasImages =
          event.imagePaths != null && event.imagePaths!.isNotEmpty;

      if (hasText || hasImages) {
        add(
          SendMessageEvent(
            userId: event.userId,
            conversationId: conversationId,
            text: event.firstMessage,
            imagePaths: event.imagePaths,
          ),
        );
      }
    } catch (e) {
      _emitErrorAsMessage(e, emit);
    }
  }

  Future<void> _sendMessage(
    SendMessageEvent event,
    Emitter<BotState> emit,
  ) async {
    if (_isSending) return;

    final hasText = event.text.trim().isNotEmpty;

    final hasImages = event.imagePaths != null && event.imagePaths!.isNotEmpty;

    if (!hasText && !hasImages) return;

    _isSending = true;

    try {
      final isFirstMessage = state.messages.isEmpty;

      final userMessage = Message(
        id: const Uuid().v4(),
        text: event.text,
        imagePaths: event.imagePaths,
        isUser: true,
        createdAt: DateTime.now(),
      );

      final updatedMessages = [...state.messages, userMessage];

      emit(
        state.copyWith(
          messages: List<Message>.from(updatedMessages),
          isTyping: true,
        ),
      );

      await chatRepository.sendMessage(
        userId: event.userId,
        conversationId: event.conversationId,
        message: userMessage,
      );

      if (isFirstMessage) {
        final title = _generateTitle(event.text);

        await chatRepository.updateConversationTitle(
          userId: event.userId,
          conversationId: event.conversationId,
          title: title,
        );

        final conversations = await chatRepository.getConversations(
          event.userId,
        );

        emit(state.copyWith(conversations: conversations));
      }

      final history = updatedMessages.takeLast(12);

      final response = await chatbotRepo.sendMessage(
        history: history,
        imagePaths: event.imagePaths,
      );

      Message botMessage = Message(
        id: const Uuid().v4(),
        text: "",
        isUser: false,
        isStreaming: true,
        createdAt: DateTime.now(),
      );

      final tempList = [...updatedMessages, botMessage];

      emit(
        state.copyWith(messages: List<Message>.from(tempList), isTyping: false),
      );

      final currentSession = ++_streamSession;

      String current = "";

      int lastEmit = DateTime.now().millisecondsSinceEpoch;

      final int chunkSize;

      if (response.length < 300) {
        chunkSize = 2;
      } else if (response.length < 1000) {
        chunkSize = 3;
      } else if (response.length < 3000) {
        chunkSize = 5;
      } else {
        chunkSize = 7;
      }

      final int streamDelay;

      if (response.length < 300) {
        streamDelay = 28;
      } else if (response.length < 1000) {
        streamDelay = 22;
      } else if (response.length < 3000) {
        streamDelay = 16;
      } else {
        streamDelay = 12;
      }

      for (int i = 0; i < response.length; i += chunkSize) {
        if (currentSession != _streamSession) {
          if (current.trim().isNotEmpty) {
            final cancelledMessage = botMessage.copyWith(
              text: current,
              isStreaming: false,
            );

            tempList[tempList.length - 1] = cancelledMessage;

            if (!emit.isDone) {
              emit(
                state.copyWith(
                  messages: List<Message>.from(tempList),
                  isTyping: false,
                ),
              );
            }

            try {
              await chatRepository.sendMessage(
                userId: event.userId,
                conversationId: event.conversationId,
                message: cancelledMessage,
              );
            } catch (_) {}
          }

          return;
        }

        current += response.substring(
          i,
          (i + chunkSize).clamp(0, response.length),
        );

        botMessage = botMessage.copyWith(text: current, isStreaming: true);

        tempList[tempList.length - 1] = botMessage;

        final now = DateTime.now().millisecondsSinceEpoch;

        if (now - lastEmit > 140 || i + chunkSize >= response.length) {
          if (emit.isDone) return;

          emit(state.copyWith(messages: List<Message>.from(tempList)));

          lastEmit = now;
        }

        await Future.delayed(
          Duration(
            milliseconds: streamDelay + (DateTime.now().millisecond % 6),
          ),
        );
      }

      final finalMessage = botMessage.copyWith(
        text: current,
        isStreaming: false,
      );

      tempList[tempList.length - 1] = finalMessage;

      emit(
        state.copyWith(messages: List<Message>.from(tempList), isTyping: false),
      );

      await chatRepository.sendMessage(
        userId: event.userId,
        conversationId: event.conversationId,
        message: finalMessage,
      );
    } catch (e, stackTrace) {
      debugPrint("CHAT ERROR: $e");

      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrintStack(stackTrace: stackTrace);
      }
      
      final errorText = ApiErrorHandler.getMessage(e);

      final errorMessage = Message(
        id: const Uuid().v4(),
        text: errorText,
        isUser: false,
        createdAt: DateTime.now(),
      );

      final updated = [...state.messages, errorMessage];

      try {
        await chatRepository.sendMessage(
          userId: event.userId,
          conversationId: event.conversationId,
          message: errorMessage,
        );
      } catch (_) {}

      emit(
        state.copyWith(messages: List<Message>.from(updated), isTyping: false),
      );
    } finally {
      _isSending = false;
    }
  }

  Future<void> _selectConversation(
    SelectConversationEvent event,
    Emitter<BotState> emit,
  ) async {
    _streamSession++;

    emit(
      state.copyWith(
        conversationId: event.conversationId,
        messages: [],
        isLoading: true,
        isTyping: false,
      ),
    );

    add(
      LoadMessagesEvent(userId: userId, conversationId: event.conversationId),
    );
  }

  Future<void> _loadConversations(
    LoadConversationsEvent event,
    Emitter<BotState> emit,
  ) async {
    try {
      final conversations = await chatRepository.getConversations(event.userId);

      emit(state.copyWith(conversations: conversations));
    } catch (e) {
      _emitErrorAsMessage(e, emit);
    }
  }

  Future<void> _deleteConversation(
    DeleteConversationEvent event,
    Emitter<BotState> emit,
  ) async {
    try {
      await chatRepository.deleteConversation(
        userId: event.userId,
        conversationId: event.conversationId,
      );

      final conversations = await chatRepository.getConversations(event.userId);

      emit(
        state.copyWith(
          conversations: conversations,
          messages: [],
          conversationId: null,
        ),
      );
    } catch (e) {
      _emitErrorAsMessage(e, emit);
    }
  }

  Future<void> _renameConversation(
    RenameConversationEvent event,
    Emitter<BotState> emit,
  ) async {
    try {
      await chatRepository.renameConversation(
        userId: event.userId,
        conversationId: event.conversationId,
        newTitle: event.newTitle,
      );

      final conversations = await chatRepository.getConversations(event.userId);

      emit(state.copyWith(conversations: conversations));
    } catch (e) {
      _emitErrorAsMessage(e, emit);
    }
  }

  void _emitErrorAsMessage(dynamic e, Emitter<BotState> emit) {
    final errorText = ApiErrorHandler.getMessage(e);

    final errorMessage = Message(
      id: const Uuid().v4(),
      text: errorText,
      isUser: false,
      createdAt: DateTime.now(),
    );

    emit(
      state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        isTyping: false,
      ),
    );
  }

  void cancelStreaming() {
    _streamSession++;
  }

  String _generateTitle(String text) {
    return text.replaceAll("\n", " ").trim().split(" ").take(5).join(" ");
  }
}
