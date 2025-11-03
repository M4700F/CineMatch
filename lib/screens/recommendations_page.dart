import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../providers/language_provider.dart';
import '../providers/recommendation_provider.dart';
import '../services/movie_api_service.dart';
import '../utils/app_localizations.dart';
import '../widgets/gradient_background.dart';

class RecommendationsPage extends ConsumerStatefulWidget {
  const RecommendationsPage({super.key});

  @override
  ConsumerState<RecommendationsPage> createState() =>
      _RecommendationsPageState();
}

class _RecommendationsPageState extends ConsumerState<RecommendationsPage> {
  Future<void> _onRefresh() {
    return ref.read(recommendationProvider.notifier).refreshRecommendations();
  }

  void _openPreferences() {
    context.push('/genre-preferences');
  }

  void _openMovieDetails(Movie movie) {
    context.push('/movie/${movie.id}', extra: movie);
  }

  @override
  Widget build(BuildContext context) {
    final recommendationState = ref.watch(recommendationProvider);
    final localizations = ref.watch(localizationProvider);
    final heroMovie = recommendationState.recommendations.isNotEmpty
        ? recommendationState.recommendations.first
        : null;

    final remaining = heroMovie != null
        ? recommendationState.recommendations.skip(1).toList()
        : recommendationState.recommendations;

    final trending = remaining.take(6).toList();
    final basedOnTaste = remaining.skip(trending.length).take(6).toList();
    final keepExploring = remaining
        .skip(trending.length + basedOnTaste.length)
        .toList();

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(localizations.forYou),
          actions: [
            IconButton(
              onPressed: _openPreferences,
              tooltip: localizations.personalizeRecommendations,
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        body: Column(
          children: [
            if (recommendationState.isRefreshing)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: _buildBody(
                context,
                recommendationState,
                localizations,
                heroMovie,
                trending,
                basedOnTaste,
                keepExploring,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    RecommendationState state,
    AppLocalizations localizations,
    Movie? heroMovie,
    List<Movie> trending,
    List<Movie> basedOnTaste,
    List<Movie> keepExploring,
  ) {
    if (state.isLoading && state.recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.fetchingRecommendations,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (state.error != null && state.recommendations.isEmpty) {
      return _buildErrorState(context, localizations, state.error!);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.personalizeRecommendations,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.adjustGenrePreferences,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _openPreferences,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(localizations.personalizeRecommendations),
                  ),
                  if (state.error != null && state.recommendations.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _ErrorBanner(
                        message: state.error!,
                        actionLabel: localizations.retry,
                        onRetry: () => ref
                            .read(recommendationProvider.notifier)
                            .loadRecommendations(forceRefresh: true),
                      ),
                    ),
                  if (state.lastUpdated != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Updated ${_timeAgo(state.lastUpdated!)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (heroMovie != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _HeroRecommendationCard(
                  movie: heroMovie,
                  onTap: _openMovieDetails,
                ),
              ),
            ),
          if (trending.isNotEmpty)
            SliverToBoxAdapter(
              child: _RecommendationSection(
                title: localizations.trendingForYou,
                movies: trending,
                onMovieTap: _openMovieDetails,
              ),
            ),
          if (basedOnTaste.isNotEmpty)
            SliverToBoxAdapter(
              child: _RecommendationSection(
                title: localizations.basedOnYourTaste,
                movies: basedOnTaste,
                onMovieTap: _openMovieDetails,
              ),
            ),
          if (keepExploring.isNotEmpty)
            SliverToBoxAdapter(
              child: _RecommendationSection(
                title: localizations.keepExploring,
                movies: keepExploring,
                onMovieTap: _openMovieDetails,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations localizations,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.failedToLoad,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref
                  .read(recommendationProvider.notifier)
                  .loadRecommendations(forceRefresh: true),
              child: Text(localizations.retry),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime timestamp) {
    final minutes = DateTime.now().difference(timestamp).inMinutes;
    if (minutes < 1) return 'Just now';
    if (minutes == 1) return '1 minute ago';
    if (minutes < 60) return '$minutes minutes ago';
    final hours = (minutes / 60).floor();
    if (hours == 1) return '1 hour ago';
    if (hours < 24) return '$hours hours ago';
    final days = (hours / 24).floor();
    if (days == 1) return '1 day ago';
    return '$days days ago';
  }
}

class _HeroRecommendationCard extends StatelessWidget {
  final Movie movie;
  final void Function(Movie) onTap;

  const _HeroRecommendationCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final posterUrl = MovieApiService.getMoviePosterUrl(movie);

    return GestureDetector(
      onTap: () => onTap(movie),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.network(
                posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.movie,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (movie.year != null)
                        _HeroTag(label: movie.year.toString()),
                      if (movie.genres != null && movie.genres!.isNotEmpty)
                        ...movie.genres!
                            .take(2)
                            .map((genre) => _HeroTag(label: genre)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  final String label;

  const _HeroTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final void Function(Movie) onMovieTap;

  const _RecommendationSection({
    required this.title,
    required this.movies,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final movie = movies[index];
                final posterUrl = MovieApiService.getMoviePosterUrl(movie);

                return SizedBox(
                  width: 140,
                  child: GestureDetector(
                    onTap: () => onMovieTap(movie),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              posterUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                    child: Icon(
                                      Icons.movie_outlined,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (movie.year != null)
                          Text(
                            movie.year.toString(),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemCount: movies.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onRetry;

  const _ErrorBanner({
    required this.message,
    required this.actionLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
