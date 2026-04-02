import 'package:chat_bot/features/chat_bot/domain/repository/chatbot_repo.dart';

class SendMessageUseCase {
  SendMessageUseCase({required this.repo});

  final ChatbotRepo repo;

  Future<String> call({
    required String message,
    List<String>? imagePaths,
  }) {
    
    if (message.trim().isEmpty && imagePaths == null) {
      throw Exception("Message or image required");
    }

    return repo.sendMessage(
      message: message,
      imagePath: imagePaths,
    );
  }
}