import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_helper.dart';
import '../models/api_error.dart';

class ApiService {
  // static const String baseUrl = "http://localhost:8080/api/v1/auth";
  static final String baseUrl = "${ApiConfig.baseUrl}/api/v1/auth";

  // Example: "http://192.168.0.105:8080/api/v1/auth"

  // REGISTER
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String about,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    print('📝 Registration request to: $url');
    print('📧 Email: $email');

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "name": name,
              "email": email,
              "password": password,
              "about": about,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('📡 Registration Response Status: ${response.statusCode}');
      print('📄 Registration Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Parse the error response and throw ApiError
        final apiError = ApiError.fromResponse(
          response.statusCode,
          response.body,
        );
        throw apiError;
      }
    } catch (e) {
      print('🚨 Registration Exception: $e');
      rethrow; // Rethrow to preserve ApiError type
    }
  }

  // LOGIN
  static Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    print('🔐 Login request to: $url');
    print('📧 Email: $email');

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"username": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      print('📡 Login Response Status: ${response.statusCode}');
      print('📄 Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token']; // JWT token
      } else {
        // Parse the error response and throw ApiError
        final apiError = ApiError.fromResponse(
          response.statusCode,
          response.body,
        );
        throw apiError;
      }
    } catch (e) {
      print('🚨 Login Exception: $e');
      rethrow; // Rethrow to preserve ApiError type
    }
  }

  // GET PROFILE (calls /me)
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final url = Uri.parse('$baseUrl/me');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: token invalid or expired');
      } else {
        throw Exception(
          'Failed to load user profile: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  // RESEND VERIFICATION EMAIL
  static Future<void> resendVerificationEmail({required String email}) async {
    final url = Uri.parse('$baseUrl/resend-verification?email=$email');

    print('📧 Resending verification email to: $email');

    try {
      final response = await http
          .post(url, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 10));

      print('📡 Resend Verification Response Status: ${response.statusCode}');
      print('📄 Resend Verification Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Verification email sent successfully');
        return;
      } else {
        // Parse the error response and throw ApiError
        final apiError = ApiError.fromResponse(
          response.statusCode,
          response.body,
        );
        throw apiError;
      }
    } catch (e) {
      print('🚨 Resend Verification Exception: $e');
      rethrow;
    }
  }
}
