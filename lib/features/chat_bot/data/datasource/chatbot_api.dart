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

        final parts = <Map<String, dynamic>>[];

        if (msg.text.trim().isNotEmpty) {
          parts.add({"text": msg.text.trim()});
        }

        if (i == history.length - 1 &&
            msg.isUser &&
            imagePaths != null &&
            imagePaths.isNotEmpty) {
          final imageParts = await Future.wait(
            imagePaths.map((path) async {
              final file = File(path);

              final bytes = await file.readAsBytes();

              return {
                "inlineData": {
                  "mimeType": _getMimeType(path),
                  "data": base64Encode(bytes),
                },
              };
            }),
          );

          parts.addAll(imageParts);
        }

        if (parts.isEmpty) continue;

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

      print("API RESPONSE: $data");

      final candidates = data["candidates"];

      if (candidates == null || candidates.isEmpty) {
        throw Exception("No response generated");
      }

      final parts = candidates[0]?["content"]?["parts"] as List<dynamic>?;

      if (parts == null || parts.isEmpty) {
        throw Exception("Empty response parts");
      }

      final text = parts
          .where((e) => e["text"] != null)
          .map((e) => e["text"].toString())
          .join();

      if (text.trim().isEmpty) {
        throw Exception("AI returned empty text");
      }

      return text;
    } on DioException catch (e) {
      print("DIO ERROR: ${e.response?.data}");

      final statusCode = e.response?.statusCode;

      if (statusCode == 429) {
        final errorData = e.response?.data.toString() ?? "";

        if (errorData.contains("quota")) {
          throw Exception(
            "Daily AI quota exceeded. Please try later or enable billing.",
          );
        }

        throw Exception("Too many requests sent. Please wait a moment.");
      }

      if (statusCode == 401) {
        throw Exception("Invalid API key.");
      }

      if (statusCode == 403) {
        throw Exception("Access denied.");
      }

      if (statusCode == 500) {
        throw Exception("Server error from AI API.");
      }

      throw Exception(e.response?.data.toString() ?? "Network request failed");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      print("CHAT ERROR: $e");
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
