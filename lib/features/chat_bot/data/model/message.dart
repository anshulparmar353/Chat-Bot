class Message {
  final String text;
  final List<String>? imagePaths;
  final bool isUser;

  Message({required this.text, this.imagePaths, required this.isUser});

  Message copyWith({String? text, List<String>? imagePaths, bool? isUser}) {
    return Message(
      text: text ?? this.text,
      imagePaths: imagePaths ?? this.imagePaths,
      isUser: isUser ?? this.isUser,
    );
  }
}
