import 'package:chat_bot/features/chat_bot/domain/entities/conversation.dart';
import 'package:chat_bot/features/chat_bot/domain/entities/message.dart';
import 'package:equatable/equatable.dart';

class BotState extends Equatable {
  final List<Message> messages;
  final List<Conversation> conversations; 
  final String? conversationId;
  final bool isLoading;
  final bool isTyping;
  final String? error;

  const BotState({
    this.messages = const [],
    this.conversations = const [],
    this.conversationId,
    this.isLoading = false,
    this.isTyping = false,
    this.error,
  });

  BotState copyWith({
    List<Message>? messages,
    List<Conversation>? conversations,
    String? conversationId,
    bool? isLoading,
    bool? isTyping,
    String? error,
  }) {
    return BotState(
      messages: messages ?? this.messages,
      conversations: conversations ?? this.conversations,
      conversationId: conversationId ?? this.conversationId,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    conversations,
    conversationId,
    isLoading,
    isTyping,
    error,
  ];
}
