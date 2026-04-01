import 'package:equatable/equatable.dart';

abstract class BotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends BotEvent {
  final String message;
  final String? imagePath;

  SendMessageEvent({
    required this.message,
    this.imagePath,
  });

  @override
  List<Object?> get props => [message, imagePath];
}