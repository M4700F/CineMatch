import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';
import '../models/new_user_preferences.dart';
import '../services/recommendation_service.dart';
import '../utils/api_exception.dart';
import 'auth_provider.dart';

class RecommendationState {
  final List<Movie> recommendations;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? lastUpdated;

  RecommendationState({
    List<Movie>? recommendations,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
  }) : recommendations = recommendations ?? const [];

  RecommendationState copyWith({
    List<Movie>? recommendations,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return RecommendationState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class RecommendationNotifier extends StateNotifier<RecommendationState> {
  RecommendationNotifier(this.ref) : super(RecommendationState()) {
    ref.listen<AuthState>(authProvider, _handleAuthChange);
    loadRecommendations();
  }

  final Ref ref;

  void _handleAuthChange(AuthState? _, AuthState next) {
    if (!next.isAuthenticated) {
      state = RecommendationState();
      return;
    }

    if (next.token != null) {
      loadRecommendations(forceRefresh: true);
    }
  }

  Future<void> loadRecommendations({bool forceRefresh = false}) async {
    if (state.isLoading) {
      return;
    }

    if (!forceRefresh && state.recommendations.isNotEmpty) {
      return;
    }

    final token = ref.read(authTokenProvider);
    if (token == null || token.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        recommendations: const [],
      );
      state = state.copyWith(recommendations: const [], lastUpdated: null);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response =
          await RecommendationService.getPersonalizedRecommendations(
            token: token,
          );
      state = state.copyWith(
        recommendations: response.recommendations,
        isLoading: false,
        lastUpdated: DateTime.now(),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshRecommendations() async {
    if (state.isRefreshing) {
      return;
    }

    final token = ref.read(authTokenProvider);
    if (token == null || token.isEmpty) {
      state = state.copyWith(isRefreshing: false);
      return;
    }

    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final response =
          await RecommendationService.getPersonalizedRecommendations(
            token: token,
          );
      state = state.copyWith(
        recommendations: response.recommendations,
        isRefreshing: false,
        lastUpdated: DateTime.now(),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void applyExternalRecommendations(List<Movie> movies) {
    state = state.copyWith(
      recommendations: movies,
      lastUpdated: DateTime.now(),
      clearError: true,
    );
  }
}

final recommendationProvider =
    StateNotifierProvider<RecommendationNotifier, RecommendationState>((ref) {
      return RecommendationNotifier(ref);
    });

class GenrePreferencesState {
  final NewUserPreferences preferences;
  final bool isSubmitting;
  final bool hasCompleted;
  final List<Movie> recommendations;
  final String? error;
  final DateTime? lastSubmitted;

  GenrePreferencesState({
    NewUserPreferences? preferences,
    this.isSubmitting = false,
    this.hasCompleted = false,
    List<Movie>? recommendations,
    this.error,
    this.lastSubmitted,
  }) : preferences = preferences ?? NewUserPreferences(),
       recommendations = recommendations ?? const [];

  GenrePreferencesState copyWith({
    NewUserPreferences? preferences,
    bool? isSubmitting,
    bool? hasCompleted,
    List<Movie>? recommendations,
    String? error,
    bool clearError = false,
    DateTime? lastSubmitted,
  }) {
    return GenrePreferencesState(
      preferences: preferences ?? this.preferences,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasCompleted: hasCompleted ?? this.hasCompleted,
      recommendations: recommendations ?? this.recommendations,
      error: clearError ? null : (error ?? this.error),
      lastSubmitted: lastSubmitted ?? this.lastSubmitted,
    );
  }
}

class GenrePreferencesNotifier extends StateNotifier<GenrePreferencesState> {
  GenrePreferencesNotifier(this.ref) : super(GenrePreferencesState()) {
    final authState = ref.read(authProvider);
    final initialUser = authState.user;
    if (authState.isAuthenticated && initialUser != null) {
      Future.microtask(() => _loadPreferencesFromBackend(initialUser.id));
    }

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!next.isAuthenticated) {
        state = GenrePreferencesState();
        return;
      }

      final user = next.user;
      if (user != null && user.id.isNotEmpty) {
        Future.microtask(() => _loadPreferencesFromBackend(user.id));
      }
    });
  }

  final Ref ref;

  Future<bool> shouldPromptForUser(String userId) async {
    if (userId.isEmpty) {
      state = state.copyWith(hasCompleted: false);
      return false;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _prefsKey(userId);
      final completed = prefs.getBool(key) ?? false;
      state = state.copyWith(hasCompleted: completed);
      return !completed;
    } catch (_) {
      state = state.copyWith(hasCompleted: false);
      return false;
    }
  }

  void updatePreference(String key, double value) {
    state = state.copyWith(preferences: state.preferences.update(key, value));
  }

  void resetPreferences() {
    state = GenrePreferencesState(hasCompleted: state.hasCompleted);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> submitPreferences() async {
    if (state.isSubmitting) {
      return;
    }

    final token = ref.read(authTokenProvider);
    final user = ref.read(currentUserProvider);

    if (token == null || token.isEmpty || user == null) {
      state = state.copyWith(
        error: 'Authentication required to submit preferences',
      );
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final response =
          await RecommendationService.getRecommendationsByPreferences(
            token: token,
            preferences: state.preferences,
          );

      await _markCompleted(user.id);
      await _loadPreferencesFromBackend(user.id);

      state = state.copyWith(
        recommendations: response.recommendations,
        isSubmitting: false,
        hasCompleted: true,
        lastSubmitted: DateTime.now(),
        clearError: true,
      );

      ref
          .read(recommendationProvider.notifier)
          .applyExternalRecommendations(response.recommendations);
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }

  Future<void> _markCompleted(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey(userId), true);
      state = state.copyWith(hasCompleted: true);
    } catch (_) {
      // Best-effort persistence; ignore storage errors.
    }
  }

  Future<void> _loadPreferencesFromBackend(String userId) async {
    try {
      final token = ref.read(authTokenProvider);
      if (token == null || token.isEmpty) {
        return;
      }
      final savedPreferences =
          await RecommendationService.getUserPreferences(token: token);
      state = state.copyWith(preferences: savedPreferences);
      if (!savedPreferences.isDefault) {
        await _markCompleted(userId);
      }
    } catch (_) {
      // Ignore backend errors; user can retry fetching preferences later.
    }
  }

  static String _prefsKey(String userId) =>
      'genre_preferences_completed_$userId';
}

final genrePreferencesProvider =
    StateNotifierProvider<GenrePreferencesNotifier, GenrePreferencesState>((
      ref,
    ) {
      return GenrePreferencesNotifier(ref);
    });

class SimilarMoviesArgs {
  final String movieId;
  final int limit;

  const SimilarMoviesArgs({required this.movieId, this.limit = 10});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is SimilarMoviesArgs &&
        other.movieId == movieId &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(movieId, limit);
}

final similarMoviesProvider = FutureProvider.family
    .autoDispose<List<Movie>, SimilarMoviesArgs>((ref, args) async {
      final token = ref.read(authTokenProvider);
      return RecommendationService.getSimilarMovies(
        movieId: args.movieId,
        limit: args.limit,
        token: token,
      );
    });
