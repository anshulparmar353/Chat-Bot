import 'dart:convert';
import 'dart:io';
import 'package:chat_bot/core/network/api_endpoints.dart';
import 'package:chat_bot/features/chat_bot/domain/entities/message.dart';
import 'package:dio/dio.dart';

class ChatbotApi {
  final Dio dio;

  const ChatbotApi(this.dio);

  Future<String> call({
    required List<Message> history,
    List<String>? imagePaths,
  }) async {
    try {
      if (history.isEmpty) {
        throw Exception("History cannot be empty");
      }

      final contents = <Map<String, dynamic>>[];

      for (int i = 0; i < history.length; i++) {
        final msg = history[i];

        List<Map<String, dynamic>> parts = [];

        // Text
        if (msg.text.isNotEmpty) {
          parts.add({"text": msg.text});
        }

        // Images ONLY for latest user message
        if (i == history.length - 1 &&
            msg.isUser &&
            imagePaths != null &&
            imagePaths.isNotEmpty) {
          final imageParts = await Future.wait(
            imagePaths.map((path) async {
              final file = File(path);
              final bytes = await file.readAsBytes();

              return {
                "inline_data": {
                  "mime_type": _getMimeType(path),
                  "data": base64Encode(bytes),
                },
              };
            }),
          );

          parts.addAll(imageParts);
        }

        contents.add({"role": msg.isUser ? "user" : "model", "parts": parts});
      }

      final response = await dio
          .post(
            "${ApiEndpoints.baseUrl}${ApiEndpoints.generateContent}?key=${ApiEndpoints.apiKey}",
            data: {
              "system_instruction": {
                "parts": [
                  {
                    "text":
                        "You are a helpful AI assistant. Answer clearly in markdown.",
                  },
                ],
              },
              "contents": contents,
            },
            options: Options(headers: {"Content-Type": "application/json"}),
          )
          .timeout(const Duration(seconds: 30));

      final data = response.data;

      final candidates = data?["candidates"] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception("No candidates in response");
      }

      final content = candidates.first["content"];
      final responseParts = (content?["parts"] as List?) ?? [];

      final text = responseParts
          .where((p) => p is Map && p["text"] != null)
          .map((p) => p["text"] as String)
          .join();

      if (text.isEmpty) {
        throw Exception("Empty response text");
      }

      return text;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  String _getMimeType(String path) {
    final lower = path.toLowerCase();

    if (lower.endsWith(".png")) return "image/png";
    if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
      return "image/jpeg";
    }
    return "image/jpeg";
  }
}
