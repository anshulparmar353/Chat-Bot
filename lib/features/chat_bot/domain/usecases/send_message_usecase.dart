import 'package:chat_bot/features/chat_bot/domain/entities/message.dart';
import 'package:chat_bot/features/chat_bot/domain/repository/chat_repository.dart';
import 'package:chat_bot/features/chat_bot/domain/repository/chatbot_repo.dart';
import 'package:uuid/uuid.dart';

class SendMessageUseCase {
  final ChatRepository chatRepository;
  final ChatbotRepo chatbotRepo;

  SendMessageUseCase({required this.chatRepository, required this.chatbotRepo});

  Future<List<Message>> call({
    required String userId,
    required String conversationId,
    required String text,
  }) async {
    final now = DateTime.now();

    final userMessage = Message(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      createdAt: now,
    );

    await chatRepository.sendMessage(
      userId: userId,
      conversationId: conversationId,
      message: userMessage,
    );

    final history = [userMessage, userMessage];

    final response = await chatbotRepo.sendMessage(history: history);

    final botMessage = Message(
      id: const Uuid().v4(),
      text: response,
      isUser: false,
      createdAt: DateTime.now(),
    );

    await chatRepository.sendMessage(
      userId: userId,
      conversationId: conversationId,
      message: botMessage,
    );

    return [userMessage, botMessage];
  }
}
