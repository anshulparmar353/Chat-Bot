import 'package:equatable/equatable.dart';

abstract class BotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends BotEvent {
  final String message;
  final List<String>? imagePaths;

  SendMessageEvent({
    required this.message,
    this.imagePaths
  });

  @override
  List<Object?> get props => [message, imagePaths];
}