import 'dart:convert';
import 'dart:io';
import 'package:chat_bot/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

class ChatbotApi {
  final Dio dio;

  const ChatbotApi(this.dio);

  Future<String> call(String? message, List<String>? imagePaths) async {
    try {
      if ((message == null || message.isEmpty) &&
          (imagePaths == null || imagePaths.isEmpty)) {
        throw Exception("Empty request");
      }

      List<Map<String, dynamic>> requestParts = [];

      if (message != null && message.isNotEmpty) {
        requestParts.add({"text": message});
      }

      if (imagePaths != null && imagePaths.length > 5) {
        throw Exception("Max 5 images allowed");
      }

      if (imagePaths != null && imagePaths.isNotEmpty) {
        final imageParts = await Future.wait(
          imagePaths.map((path) async {
            final file = File(path);

            final size = await file.length();
            if (size > 5 * 1024 * 1024) {
              throw Exception("Image too large (max 5MB)");
            }

            final bytes = await file.readAsBytes();
            final base64Image = base64Encode(bytes);

            return {
              "inline_data": {
                "mime_type": _getMimeType(path),
                "data": base64Image,
              },
            };
          }),
        );

        requestParts.addAll(imageParts);
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

              "contents": [
                {"role": "user", "parts": requestParts},
              ],
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
    } on DioException catch (e) {
      throw Exception("API Error: ${e.response?.data ?? e.message}");
    } catch (e) {
      throw Exception("Unexpected Error: $e");
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
