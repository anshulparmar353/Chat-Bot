abstract class BotEvent {}

class LoadMessagesEvent extends BotEvent {
  final String userId;
  final String conversationId;

  LoadMessagesEvent({required this.userId, required this.conversationId});
}

class SendMessageEvent extends BotEvent {
  final String userId;
  final String conversationId;
  final String text;
  final List<String>? imagePaths;

  SendMessageEvent({
    required this.userId,
    required this.conversationId,
    required this.text,
    this.imagePaths,
  });
}

class CreateConversationEvent extends BotEvent {
  final String userId;
  final String firstMessage;
  final List<String>? imagePaths;

  CreateConversationEvent({
    required this.userId,
    required this.firstMessage,
    this.imagePaths,
  });
}

class SelectConversationEvent extends BotEvent {
  final String conversationId;

  SelectConversationEvent(this.conversationId);
}

class LoadConversationsEvent extends BotEvent {
  final String userId;

  LoadConversationsEvent(this.userId);
}

class DeleteConversationEvent extends BotEvent {
  final String userId;
  final String conversationId;

  DeleteConversationEvent({required this.userId, required this.conversationId});
}

class RenameConversationEvent extends BotEvent {
  final String userId;
  final String conversationId;
  final String newTitle;

  RenameConversationEvent({
    required this.userId,
    required this.conversationId,
    required this.newTitle,
  });
}

class ClearChatEvent extends BotEvent {}
