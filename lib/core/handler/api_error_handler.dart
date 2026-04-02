import 'dart:io';
import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String getMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "The request is taking longer than expected. Please try again.";

        case DioExceptionType.badResponse:
          return _handleStatusCode(error.response?.statusCode);

        case DioExceptionType.connectionError:
          return "It seems you're offline. Check your internet connection.";

        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return "No internet connection.";
          }
          return "Something went wrong. Please try again.";

        default:
          return "Unexpected error occurred.";
      }
    }

    return "Something went wrong.";
  }

  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return "Invalid request. Please try again.";
      case 401:
      case 403:
        return "Authentication failed. Check API key.";
      case 404:
        return "Requested resource not found.";
      case 500:
      case 502:
      case 503:
        return "Server is having trouble. Try again later.";
      default:
        return "Something went wrong. Please try again.";
    }
  }
}