import 'package:chat_bot/features/chat_bot/domain/repository/chatbot_repo.dart';

class SendMessageUseCase {
  SendMessageUseCase({required this.repo});

  final ChatbotRepo repo;

  Future<String> call({
    required String message,
    List<String>? imagePath,
  }) {
    
    if (message.trim().isEmpty && imagePath == null) {
      throw Exception("Message or image required");
    }

    return repo.sendMessage(
      message: message,
      imagePath: imagePath,
    );
  }
}