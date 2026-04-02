import 'package:chat_bot/features/chat_bot/data/model/message.dart';
import 'package:chat_bot/features/chat_bot/domain/usecases/chatbot_usecases.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_event.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BotBloc extends Bloc<BotEvent, BotState> {
  final SendMessageUseCase sendMessage;

  BotBloc(this.sendMessage) : super(BotInitialState()) {
    on<SendMessageEvent>(_onMessageSend);
  }

  Future<void> _onMessageSend(
    SendMessageEvent event,
    Emitter<BotState> emit,
  ) async {
    List<Message> messages = [];

    final hasInput =
        event.message.isNotEmpty ||
        (event.imagePaths != null && event.imagePaths!.isNotEmpty);

    if (hasInput) {
      messages.add(
        Message(
          text: event.message,
          imagePaths: event.imagePaths,
          isUser: true,
        ),
      );

      emit(BotTypingState(messages: List.from(messages)));
    }

    try {
      if (hasInput) {
        final response = await sendMessage(
          message: event.message,
          imagePath: event.imagePaths,
        );

        messages.add(Message(text: "", isUser: false));

        String currentText = "";
        DateTime lastEmitTime = DateTime.now();

        for (int i = 0; i < response.length; i++) {
          currentText += response[i];

          messages[messages.length - 1] = messages.last.copyWith(
            text: currentText,
          );

          final now = DateTime.now();

          if (now.difference(lastEmitTime).inMilliseconds > 50) {
            emit(BotStreamingState(messages: List.from(messages)));
            lastEmitTime = now;
          }
        }

        emit(BotStreamingState(messages: List.from(messages)));
      }

      emit(BotMessageState(messages: List.from(messages)));
    } catch (e) {
      emit(BotErrorState(messages: List.from(messages), error: e.toString()));
    }
  }
}
