import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String text;
  final bool isUser;
  final String? imagePath;

  const Message({required this.text, required this.isUser, this.imagePath});

  Message copyWith({String? text, bool? isUser, String? imagePath}) {
    return Message(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  List<Object?> get props => [text, isUser, imagePath];
}
