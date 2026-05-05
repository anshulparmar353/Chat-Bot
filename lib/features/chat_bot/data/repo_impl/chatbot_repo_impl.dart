import 'package:chat_bot/features/chat_bot/data/datasource/chatbot_api.dart';
import 'package:chat_bot/features/chat_bot/domain/entities/message.dart';
import 'package:chat_bot/features/chat_bot/domain/repository/chatbot_repo.dart';

class ChatbotRepoImpl implements ChatbotRepo {
  ChatbotRepoImpl({required this.api});

  final ChatbotApi api;

  @override
  Future<String> sendMessage({
    required List<Message> history,
    List<String>? imagePaths,
  }) async {
    return await api.call(history: history, imagePaths: imagePaths);
  }
}
