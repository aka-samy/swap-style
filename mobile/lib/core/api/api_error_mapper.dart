import 'dart:io';

import 'package:dio/dio.dart';

class ApiErrorMapper {
  static String toUserMessage(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network and try again.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 0;
          if (statusCode == 400) {
            return 'Invalid request. Please review your input and try again.';
          }
          if (statusCode == 401) {
            return 'Your session has expired. Please sign in again.';
          }
          if (statusCode == 403) {
            return 'You do not have permission to perform this action.';
          }
          if (statusCode == 404) {
            return 'Requested data was not found.';
          }
          if (statusCode >= 500) {
            return 'Server error. Please try again in a moment.';
          }
          return fallback;
        default:
          return fallback;
      }
    }

    return fallback;
  }

  static String toDebugMessage(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final path = error.requestOptions.path;
      return 'DioException(type=${error.type}, status=$status, path=$path, message=${error.message}, body=${error.response?.data})';
    }
    return error.toString();
  }
}
