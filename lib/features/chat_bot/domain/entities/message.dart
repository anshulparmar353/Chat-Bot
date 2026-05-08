class Message {
  final String id;
  final String text;
  final List<String>? imagePaths;
  final bool isUser;
  final DateTime createdAt;
  final bool isStreaming;

  const Message({
    required this.id,
    required this.text,
    this.imagePaths,
    this.isStreaming = false,
    required this.isUser,
    required this.createdAt,
  });

  Message copyWith({
    String? id,
    String? text,
    List<String>? imagePaths,
    bool? isUser,
    DateTime? createdAt,
    bool? isStreaming,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      imagePaths: imagePaths ?? this.imagePaths,
      isUser: isUser ?? this.isUser,
      isStreaming: isStreaming ?? this.isStreaming,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
