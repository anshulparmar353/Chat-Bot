import 'package:equatable/equatable.dart';

abstract class BotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMessagesEvent extends BotEvent {
  final String userId;
  final String conversationId;

  LoadMessagesEvent({required this.userId, required this.conversationId});
}

class SendMessageEvent extends BotEvent {
  final String userId;
  final String conversationId;
  final String text;

  SendMessageEvent({
    required this.userId,
    required this.conversationId,
    required this.text,
  });
}

class CreateConversationEvent extends BotEvent {
  final String userId;
  final String firstMessage;

  CreateConversationEvent({required this.userId, required this.firstMessage});
}

class SelectConversationEvent extends BotEvent {
  final String conversationId;

  SelectConversationEvent(this.conversationId);
}

class LoadConversationsEvent extends BotEvent {
  final String userId;

  LoadConversationsEvent(this.userId);
}

class ClearChatEvent extends BotEvent {}
