import 'package:chat_bot/core/handler/api_error_handler.dart';
import 'package:chat_bot/features/chat_bot/data/model/message.dart';
import 'package:chat_bot/features/chat_bot/domain/usecases/chatbot_usecases.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_event.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BotBloc extends Bloc<BotEvent, BotState> {
  final SendMessageUseCase sendMessage;

  List<Message> messages = [];

  BotBloc(this.sendMessage) : super(BotInitialState()) {
    on<SendMessageEvent>(_onMessageSend);
  }

  Future<void> _onMessageSend(
    SendMessageEvent event,
    Emitter<BotState> emit,
  ) async {
    final hasInput =
        event.message.isNotEmpty ||
        (event.imagePaths != null && event.imagePaths!.isNotEmpty);

    if (!hasInput) return;

    messages.add(
      Message(text: event.message, imagePaths: event.imagePaths, isUser: true),
    );

    emit(BotTypingState(messages: List.from(messages)));

    try {
      final response = await sendMessage(
        message: event.message,
        imagePaths: event.imagePaths,
      );

      messages.add(Message(text: "", isUser: false));

      final words = response.split(" ");
      String currentText = "";

      for (int i = 0; i < words.length; i++) {
        currentText += "${words[i]} ";

        messages[messages.length - 1] = messages.last.copyWith(
          text: currentText,
        );

        emit(BotStreamingState(messages: List.from(messages)));

        await Future.delayed(const Duration(milliseconds: 50));
      }

      emit(BotMessageState(messages: List.from(messages)));
    } catch (e) {
      final errorMessage = ApiErrorHandler.getMessage(e);

      if (messages.isNotEmpty && !messages.last.isUser) {
        messages[messages.length - 1] = messages.last.copyWith(
          text: errorMessage,
        );
      } else {
        messages.add(Message(text: errorMessage, isUser: false));
      }

      emit(BotMessageState(messages: List.from(messages)));
    }
  }
}
