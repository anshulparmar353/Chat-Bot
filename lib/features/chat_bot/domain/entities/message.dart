class Message {
  final String id;
  final String text;
  final List<String>? imageUrls; 
  final bool isUser;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.text,
    this.imageUrls,
    required this.isUser,
    required this.createdAt,
  });

  Message copyWith({
    String? id,
    String? text,
    List<String>? imageUrls,
    bool? isUser,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrls: imageUrls ?? this.imageUrls,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
