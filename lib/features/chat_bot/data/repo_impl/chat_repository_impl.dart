import 'package:chat_bot/features/chat_bot/data/datasource/chat_remote_datasource.dart';
import 'package:chat_bot/features/chat_bot/data/model/message_model.dart';
import 'package:chat_bot/features/chat_bot/domain/repository/chat_repository.dart';

import '../../domain/entities/message.dart';
import '../../domain/entities/conversation.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource remote;

  ChatRepositoryImpl(this.remote);

  @override
  Future<String> createConversation({
    required String userId,
    required String title,
  }) async {
    return await remote.createConversation(userId: userId, title: title);
  }

  @override
  Future<void> sendMessage({
    required String userId,
    required String conversationId,
    required Message message,
  }) async {
    final model = MessageModel.fromEntity(message);

    await remote.sendMessage(
      userId: userId,
      conversationId: conversationId,
      message: model,
    );
  }

  @override
  Future<void> updateConversationTitle({
    required String userId,
    required String conversationId,
    required String title,
  }) {
    return remote.updateConversationTitle(
      userId: userId,
      conversationId: conversationId,
      title: title,
    );
  }

  @override
  Future<List<Conversation>> getConversations(String userId) async {
    final models = await remote.getConversations(userId);

    return models.map((e) => e).toList();
  }

  @override
  Future<List<Message>> getMessages({
    required String userId,
    required String conversationId,
  }) async {
    final models = await remote.getMessages(
      userId: userId,
      conversationId: conversationId,
    );

    return models.map((e) => e).toList();
  }

  @override
  Future<void> deleteConversation({
    required String userId,
    required String conversationId,
  }) async {
    await remote.deleteConversation(
      userId: userId,
      conversationId: conversationId,
    );
  }
}
