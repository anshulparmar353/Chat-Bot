import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static const String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models";

  static const String generateContent =
      "/gemini-3-flash-preview:generateContent";

  static String get apiKey => dotenv.env['API_KEY'] ?? "";
}
