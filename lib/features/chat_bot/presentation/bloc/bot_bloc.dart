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

    final hasInput = event.message.isNotEmpty || event.imagePath != null;

    if (state is BotMessageState) {
      messages = List.from((state as BotMessageState).messages);
    } else if (state is BotTypingState) {
      messages = List.from((state as BotTypingState).messages);
    } else if (state is BotStreamingState) {
      messages = List.from((state as BotStreamingState).messages);
    } else if (state is BotErrorState) {
      messages = List.from((state as BotErrorState).messages);
    }

    if (hasInput) {
      messages.add(
        Message(text: event.message, imagePath: event.imagePath, isUser: true),
      );

      emit(BotTypingState(messages: List.from(messages)));
    }

    try {
      if (hasInput) {
        
        emit(BotTypingState(messages: List.from(messages)));

        final response = await sendMessage(
          message: event.message,
          imagePath: event.imagePath,
        );

        if (response.isNotEmpty) {
          messages.add(Message(text: "", isUser: false));
        }

        String currentText = "";
        DateTime lastEmitTime = DateTime.now();

        for (int i = 0; i < response.length; i++) {
          await Future.delayed(const Duration(milliseconds: 5));

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

        if (response.isNotEmpty) {
          emit(BotStreamingState(messages: List.from(messages)));
        }
      }

      emit(BotMessageState(messages: List.from(messages)));
    } catch (e) {
      emit(BotErrorState(messages: List.from(messages), error: e.toString()));
    }
  }
}
