import "package:chat_bot/features/chat_bot/data/model/conversation_model.dart";
import "package:chat_bot/features/chat_bot/data/model/message_model.dart";

abstract class ChatRemoteDatasource {
  Future<String> createConversation({
    required String userId,
    required String title,
  });

  Future<void> sendMessage({
    required String userId,
    required String conversationId,
    required MessageModel message,
  });

  Future<void> updateConversationTitle({
    required String userId,
    required String conversationId,
    required String title,
  });

  Future<List<ConversationModel>> getConversations(String userId);

  Future<List<MessageModel>> getMessages({
    required String userId,
    required String conversationId,
  });

  Future<void> deleteConversation({
    required String userId,
    required String conversationId,
  });

  Future<void> renameConversation({
    required String userId,
    required String conversationId,
    required String newTitle,
  });
}
