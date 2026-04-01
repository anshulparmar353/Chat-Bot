abstract class ChatbotRepo {
  Future<String> sendMessage({required String message, String? imagePath});
}
