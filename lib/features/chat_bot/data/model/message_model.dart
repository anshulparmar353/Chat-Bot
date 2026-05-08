import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.id,
    required super.text,
    super.imagePaths,
    required super.isUser,
    required super.createdAt,
    super.isStreaming,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String id) {
    return MessageModel(
      id: id,
      text: json['text'] ?? '',
      imagePaths: (json['imagePaths'] as List?)?.cast<String>(),
      isUser: json['isUser'] ?? true,
      isStreaming: json['isStreaming'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'imagePaths': imagePaths,
      'isUser': isUser,
      'isStreaming': isStreaming,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      text: message.text,
      imagePaths: message.imagePaths,
      isUser: message.isUser,
      isStreaming: message.isStreaming,
      createdAt: message.createdAt,
    );
  }
}
