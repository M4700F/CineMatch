import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';
import '../models/new_user_preferences.dart';
import '../models/recommendation_response.dart';
import '../utils/api_exception.dart';
import 'config_helper.dart';

class RecommendationService {
  static final String _baseUrl = '${ApiConfig.baseUrl}/api/recommendations';

  static Future<RecommendationResponse> getPersonalizedRecommendations({
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/me');
    final response = await http
        .get(uri, headers: _headers(token: token))
        .timeout(const Duration(seconds: 10));
    return _handleResponse(response);
  }

  static Future<RecommendationResponse> getRecommendationsByPreferences({
    required String token,
    required NewUserPreferences preferences,
  }) async {
    final uri = Uri.parse('$_baseUrl/by-preferences');
    final response = await http
        .post(
          uri,
          headers: _headers(token: token),
          body: jsonEncode(preferences.toJson()),
        )
        .timeout(const Duration(seconds: 20));
    return _handleResponse(response);
  }

  static Future<List<Movie>> getSimilarMovies({
    required String movieId,
    int limit = 10,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl/similar/$movieId?limit=$limit');
    final response = await http
        .get(
          uri,
          headers: _headers(token: token, includeAuth: token != null),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as List<dynamic>;
      return body
          .map((item) => Movie.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw _createException(response, 'Failed to load similar movies');
  }

  static RecommendationResponse _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return RecommendationResponse.fromJson(body);
    }

    throw _createException(response, 'Failed to load recommendations');
  }

  static ApiException _createException(
    http.Response response,
    String fallback,
  ) {
    try {
      final body = jsonDecode(response.body);
      final message = body is Map<String, dynamic>
          ? (body['message'] ?? body['error'] ?? fallback)
          : fallback;
      return ApiException(message.toString(), response.statusCode);
    } catch (_) {
      return ApiException(fallback, response.statusCode);
    }
  }

  static Map<String, String> _headers({
    String? token,
    bool includeAuth = true,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
