import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_helper.dart';

class WatchlistService {
  static final String _base = ApiConfig.baseUrl;

  // Add a movie to the user's favorites
  static Future<void> addMovieToFavorites({
    required String token,
    required String userId,
    required String movieId,
  }) async {
    final url = Uri.parse('$_base/api/watchlist/favorites/$userId/$movieId');
    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Failed to add movie to favorites (${resp.statusCode}): ${resp.body}');
    }
  }

  // Add a movie to the user's watch later list
  static Future<void> addMovieToWatchLater({
    required String token,
    required String userId,
    required String movieId,
  }) async {
    final url = Uri.parse('$_base/api/watchlist/watch-later/$userId/$movieId');
    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Failed to add movie to watch later (${resp.statusCode}): ${resp.body}');
    }
  }

  // Remove a movie from the user's favorites
  static Future<void> removeMovieFromFavorites({
    required String token,
    required String userId,
    required String movieId,
  }) async {
    final url = Uri.parse('$_base/api/watchlist/favorites/$userId/$movieId');
    final resp = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('Failed to remove movie from favorites (${resp.statusCode}): ${resp.body}');
    }
  }

  // Remove a movie from the user's watch later list
  static Future<void> removeMovieFromWatchLater({
    required String token,
    required String userId,
    required String movieId,
  }) async {
    final url = Uri.parse('$_base/api/watchlist/watch-later/$userId/$movieId');
    final resp = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('Failed to remove movie from watch later (${resp.statusCode}): ${resp.body}');
    }
  }

  // Get a list of movie IDs in the user's favorites
  static Future<List<int>> getFavoriteMovieIds({
    required String token,
  }) async {
    final url = Uri.parse('$_base/api/watchlist/my-favorites');
    final resp = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data is List) {
        return data.map((e) => e['movieId'] as int).toList();
      }
      return const [];
    }
    throw Exception('Failed to load favorite movie IDs (${resp.statusCode}): ${resp.body}');
  }

  // Get a list of movie IDs in the user's watch later list
  static Future<List<int>> getWatchLaterMovieIds({
    required String token,
  }) async {
    final url = Uri.parse('$_base/api/watchlist/my-watch-later');
    final resp = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data is List) {
        return data.map((e) => e['movieId'] as int).toList();
      }
      return const [];
    }
    throw Exception('Failed to load watch later movie IDs (${resp.statusCode}): ${resp.body}');
  }

  // Check if a movie is in favorites
  static Future<bool> isMovieInFavorites({
    required String token,
    required String userId,
    required String movieId,
  }) async {
    final favorites = await getFavoriteMovieIds(token: token);
    return favorites.contains(int.parse(movieId));
  }

  // Check if a movie is in watch later
  static Future<bool> isMovieInWatchLater({
    required String token,
    required String userId,
    required String movieId,
  }) async {
    final watchLater = await getWatchLaterMovieIds(token: token);
    return watchLater.contains(int.parse(movieId));
  }
}
