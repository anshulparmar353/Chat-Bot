import 'package:equatable/equatable.dart';
import 'package:chat_bot/features/chat_bot/data/model/message.dart';

abstract class BotState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BotInitialState extends BotState {}

class BotMessageState extends BotState {
  final List<Message> messages;

  BotMessageState({required List<Message> messages})
    : messages = List.unmodifiable(messages);

  @override
  List<Object?> get props => [messages];
}

class BotTypingState extends BotState {
  final List<Message> messages;

  BotTypingState({required List<Message> messages})
    : messages = List.unmodifiable(messages);

  @override
  List<Object?> get props => [messages];
}

class BotStreamingState extends BotState {
  final List<Message> messages;

  BotStreamingState({required List<Message> messages})
    : messages = List.unmodifiable(messages);

  @override
  List<Object?> get props => [messages];
}

class BotErrorState extends BotState {
  final List<Message> messages;
  final String error;

  BotErrorState({required this.messages, required this.error});

  @override
  List<Object?> get props => [messages, error];
}
