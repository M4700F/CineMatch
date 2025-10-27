import 'dart:convert';

class ApiError {
  final int statusCode;
  final String message;
  final bool isEmailNotVerified;

  ApiError({
    required this.statusCode,
    required this.message,
    this.isEmailNotVerified = false,
  });

  factory ApiError.fromResponse(int statusCode, String responseBody) {
    try {
      final Map<String, dynamic> json = jsonDecode(responseBody);
      final message =
          json['message'] ?? json['error'] ?? 'Unknown error occurred';

      // Check if this is an email verification error
      final isEmailNotVerified =
          statusCode == 403 &&
          (message.toLowerCase().contains('email not verified') ||
              message.toLowerCase().contains('verify your email'));

      return ApiError(
        statusCode: statusCode,
        message: message,
        isEmailNotVerified: isEmailNotVerified,
      );
    } catch (e) {
      // If response is not JSON, use the raw body
      return ApiError(
        statusCode: statusCode,
        message: responseBody.isNotEmpty ? responseBody : 'An error occurred',
      );
    }
  }

  @override
  String toString() => message;
}
