import 'movie.dart';

/// Represents the backend recommendation response payload.
class RecommendationResponse {
  final int? userId;
  final List<Movie> recommendations;

  const RecommendationResponse({this.userId, List<Movie>? recommendations})
    : recommendations = recommendations ?? const [];

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    final list = json['recommendations'] as List<dynamic>? ?? const [];
    return RecommendationResponse(
      userId: _parseUserId(json['user_id'] ?? json['userId']),
      recommendations: list
          .map((item) => Movie.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  RecommendationResponse copyWith({int? userId, List<Movie>? recommendations}) {
    return RecommendationResponse(
      userId: userId ?? this.userId,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  static int? _parseUserId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
