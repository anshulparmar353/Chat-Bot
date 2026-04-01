import 'package:chat_bot/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;
  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          queryParameters: {"key": ApiEndpoints.apiKey},
        ),
      );
}
