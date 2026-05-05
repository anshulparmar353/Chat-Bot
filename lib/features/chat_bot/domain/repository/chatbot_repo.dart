import 'package:chat_bot/features/chat_bot/domain/entities/message.dart';

abstract class ChatbotRepo {
  Future<String> sendMessage({
    required List<Message> history,
    List<String>? imagePaths,
  });
}
