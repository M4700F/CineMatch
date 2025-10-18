import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../models/movie.dart';
import '../screens/movie_details.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider
import '../services/watchlist_service.dart'; // Import WatchlistService
import '../services/movie_api_service.dart'; // Import MovieApiService
import '../services/movie_api_service.dart'; // Import MovieApiService
// import '../providers/theme_provider.dart';
// Removed tab_selection_provider import as it's no longer needed here

// Providers for fetching movie IDs
final favoriteMovieIdsProvider = FutureProvider.family<List<int>, String>((ref, token) async {
  return WatchlistService.getFavoriteMovieIds(token: token);
});

final watchLaterMovieIdsProvider = FutureProvider.family<List<int>, String>((ref, token) async {
  return WatchlistService.getWatchLaterMovieIds(token: token);
});

// Providers for fetching full Movie objects
final favoriteMoviesProvider = FutureProvider.family<List<Movie>, String>((ref, token) async {
  final movieIds = await ref.watch(favoriteMovieIdsProvider(token).future);
  if (movieIds.isEmpty) return [];
  return Future.wait(movieIds.map((id) => MovieApiService.getMovieById(id.toString())));
});

final watchLaterMoviesProvider = FutureProvider.family<List<Movie>, String>((ref, token) async {
  final movieIds = await ref.watch(watchLaterMovieIdsProvider(token).future);
  if (movieIds.isEmpty) return [];
  return Future.wait(movieIds.map((id) => MovieApiService.getMovieById(id.toString())));
});

class WatchlistPage extends ConsumerStatefulWidget {
  const WatchlistPage({super.key});

  @override
  ConsumerState<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends ConsumerState<WatchlistPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToDetails(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsPage(movie: movie),
      ),
    );
  }

  Future<void> _removeMovie(Movie movie, bool isFavorite) async {
    final token = ref.read(authTokenProvider);
    final userId = ref.read(currentUserProvider)?.id;

    if (token == null || userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User not authenticated.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      if (isFavorite) {
        await WatchlistService.removeMovieFromFavorites(
          token: token,
          userId: userId,
          movieId: movie.id,
        );
      } else {
        await WatchlistService.removeMovieFromWatchLater(
          token: token,
          userId: userId,
          movieId: movie.id,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${movie.title} removed'),
        ),
      );
      // Invalidate providers to refetch data
      ref.invalidate(favoriteMovieIdsProvider(token));
      ref.invalidate(watchLaterMovieIdsProvider(token));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove movie: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildMovieList(AsyncValue<List<Movie>> moviesAsync, bool isFavorite) {
    return moviesAsync.when(
      data: (movies) {
        if (movies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite_outline : Icons.watch_later_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isFavorite ? 'No favorites yet' : 'Watch later list is empty',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isFavorite
                      ? 'Start adding movies to your favorites'
                      : 'Add movies you want to watch later',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            final imageUrl = MovieApiService.getMoviePosterUrl(movie);

            return Card(
              elevation: 3,
              shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => _navigateToDetails(movie),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                child: Center(
                                  child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.movie_outlined,
                                      size: 48,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No Image',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (movie.rating > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      movie.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (movie.year != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 12,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        movie.year.toString(),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            if (movie.genre != null && movie.genre!.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      movie.genre!,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(authTokenProvider);

    if (token == null) {
      return const Center(child: Text('Please log in to view your watchlist.'));
    }

    final favoriteMoviesAsync = ref.watch(favoriteMoviesProvider(token));
    final watchLaterMoviesAsync = ref.watch(watchLaterMoviesProvider(token));

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(24),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, size: 16),
                    SizedBox(width: 8),
                    Text('Favorites'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.watch_later, size: 16),
                    SizedBox(width: 8),
                    Text('Watch Later'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMovieList(favoriteMoviesAsync, true),
              _buildMovieList(watchLaterMoviesAsync, false),
            ],
          ),
        ),
      ],
    );
}
}
