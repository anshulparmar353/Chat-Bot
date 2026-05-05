import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';

class MessageModel extends Message {
  final bool isStreaming;

  MessageModel({
    required super.id,
    required super.text,
    super.imageUrls,
    required super.isUser,
    required super.createdAt,
    this.isStreaming = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String id) {
    return MessageModel(
      id: id,
      text: json['text'] ?? '',
      imageUrls: (json['imageUrls'] as List?)?.cast<String>(),
      isUser: json['isUser'] ?? true,
      isStreaming: json['isStreaming'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'imageUrls': imageUrls,
      'isUser': isUser,
      'isStreaming': isStreaming,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      text: message.text,
      imageUrls: message.imageUrls,
      isUser: message.isUser,
      createdAt: message.createdAt,
    );
  }
}