import '../entities/message.dart';
import '../entities/conversation.dart';

abstract class ChatRepository {
  Future<String> createConversation({
    required String userId,
    required String title,
  });

  Future<void> sendMessage({
    required String userId,
    required String conversationId,
    required Message message,
  });

  Future<void> updateConversationTitle({
    required String userId,
    required String conversationId,
    required String title,
  });

  Future<List<Conversation>> getConversations(String userId);

  Future<List<Message>> getMessages({
    required String userId,
    required String conversationId,
  });

  Future<void> deleteConversation({
    required String userId,
    required String conversationId,
  });
}
