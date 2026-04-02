abstract class ChatbotRepo {
  Future<String> sendMessage({required String message, List<String>? imagePath});
}
