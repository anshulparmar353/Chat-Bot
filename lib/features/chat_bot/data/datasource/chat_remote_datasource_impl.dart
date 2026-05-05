import 'package:chat_bot/features/chat_bot/data/model/conversation_model.dart';
import 'package:chat_bot/features/chat_bot/data/model/message_model.dart';
import 'package:chat_bot/features/chat_bot/data/datasource/chat_remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRemoteDataSourceImpl implements ChatRemoteDatasource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> _conversationRef(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('conversations');
  }

  CollectionReference<Map<String, dynamic>> _messageRef(
    String userId,
    String conversationId,
  ) {
    return _conversationRef(userId).doc(conversationId).collection('messages');
  }

  @override
  Future<String> createConversation({
    required String userId,
    required String title,
  }) async {
    final doc = _conversationRef(userId).doc();

    final now = DateTime.now();

    final conversation = ConversationModel(
      id: doc.id,
      title: title,
      createdAt: now,
      updatedAt: now,
    );

    await doc.set(conversation.toJson());

    return doc.id;
  }

  @override
  Future<void> sendMessage({
    required String userId,
    required String conversationId,
    required MessageModel message,
  }) async {
    final msgRef = _messageRef(userId, conversationId).doc();

    await msgRef.set(message.toJson());

    await _conversationRef(userId).doc(conversationId).update({
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> updateConversationTitle({
    required String userId,
    required String conversationId,
    required String title,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .update({'title': title});
  }

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    final snapshot = await _conversationRef(
      userId,
    ).orderBy('updatedAt', descending: true).get();

    return snapshot.docs
        .map((doc) => ConversationModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String userId,
    required String conversationId,
  }) async {
    final snapshot = await _messageRef(
      userId,
      conversationId,
    ).orderBy('createdAt', descending: false).get();

    return snapshot.docs
        .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> deleteConversation({
    required String userId,
    required String conversationId,
  }) async {
    final messages = await _messageRef(userId, conversationId).get();

    for (var doc in messages.docs) {
      await doc.reference.delete();
    }

    await _conversationRef(userId).doc(conversationId).delete();
  }
}
