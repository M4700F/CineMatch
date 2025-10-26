import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_page.dart';
import 'screens/splash_screen.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/search_page.dart';
import 'screens/watchlist_page.dart';
import 'screens/profile_page.dart';
import 'screens/movie_details.dart';
import 'screens/mood_discovery_page.dart';
import 'screens/chat_page.dart';
import 'screens/myratings_page.dart';
import 'screens/settings_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'models/movie.dart';
import 'widgets/gradient_background.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

// Create a provider for the router that depends on auth state
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshNotifier(ref),
    routes: [
      // Splash Screen Route
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Chat Route
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => ChatPage(),
      ),

      // My Ratings Route
      GoRoute(
        path: '/my-ratings',
        name: 'my-ratings',
        builder: (context, state) => const MyRatingsPage(),
      ),

      // Settings Route
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // Home Tab
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                path: '/movie-details',
                name: 'movie-details-from-home',
                builder: (context, state) {
                  final movie = state.extra as Movie;
                  return MovieDetailsPage(movie: movie);
                },
              ),
            ],
          ),

          // Search Tab
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchPage(),
            routes: [
              GoRoute(
                path: '/movie-details',
                name: 'movie-details-from-search',
                builder: (context, state) {
                  final movie = state.extra as Movie;
                  return MovieDetailsPage(movie: movie);
                },
              ),
            ],
          ),

          // Watchlist Tab
          GoRoute(
            path: '/watchlist',
            name: 'watchlist',
            builder: (context, state) => const WatchlistPage(),
            routes: [
              GoRoute(
                path: '/movie-details',
                name: 'movie-details-from-watchlist',
                builder: (context, state) {
                  final movie = state.extra as Movie;
                  return MovieDetailsPage(movie: movie);
                },
              ),
            ],
          ),

          // Profile Tab
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),

          // Mood Discovery
          GoRoute(
            path: '/mood-discovery',
            name: 'mood-discovery',
            builder: (context, state) => const MoodDiscoveryPage(),
          ),
        ],
      ),

      // Standalone Movie Details (for direct navigation)
      GoRoute(
        path: '/movie/:id',
        name: 'movie-details',
        builder: (context, state) {
          final movieId = state.pathParameters['id']!;
          final movie = state.extra as Movie?;

          if (movie != null) {
            return MovieDetailsPage(movie: movie);
          }

          // If no movie object is passed, create a placeholder or fetch from API
          return MovieDetailsPage(
            movie: Movie(
              id: movieId,
              title: 'Loading...',
              rating: 0.0,
              image: '',
            ),
          );
        },
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final currentPath = state.matchedLocation;
      final isOnSplash = currentPath == '/splash';
      final isOnLogin = currentPath == '/login';
      final isOnRegister = currentPath == '/register';

      print(
        '🔄 Router redirect check: path=$currentPath, auth=$isAuthenticated, loading=$isLoading',
      );

      // CRITICAL FIX: If still checking auth status, show splash
      if (isLoading && !isAuthenticated) {
        if (!isOnSplash) {
          print('⏳ Still loading auth, showing splash');
          return '/splash';
        }
        return null; // Stay on splash
      }

      // If authenticated, redirect away from auth pages
      if (isAuthenticated && !isLoading) {
        if (isOnSplash || isOnLogin || isOnRegister) {
          print('✅ Redirecting authenticated user to /home from $currentPath');
          return '/home';
        }
        return null; // Already on a protected page
      }

      // If not authenticated and not loading, show login
      if (!isAuthenticated && !isLoading) {
        if (!isOnLogin && !isOnRegister && !isOnSplash) {
          print('🔒 Redirecting unauthenticated user to /login from $currentPath');
          return '/login';
        }
        // If on splash and not authenticated, go to login
        if (isOnSplash) {
          print('🔒 Moving from splash to login');
          return '/login';
        }
        return null; // Already on login/register
      }

      print('➡️ No redirect needed');
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you requested could not be found.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Refresh notifier for GoRouter that listens to auth changes
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

// For backwards compatibility, create a static router reference
class AppRouter {
  static GoRouter get router => throw UnimplementedError(
    'Use ref.read(routerProvider) instead of AppRouter.router',
  );
}

// Main Shell Widget that provides bottom navigation
class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;
  bool _messageShown = false;
  AuthState? _previousAuthState;

  @override
  void initState() {
    super.initState();
    _previousAuthState = ref.read(authProvider);
  }

  void _showMessageFromFab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "yo! what's the vibe check? 🎬",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(
            bottom: 80,
            right: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        final token = ref.read(authTokenProvider);
        if (token != null) {
          ref.invalidate(favoriteMovieIdsProvider(token));
          ref.invalidate(watchLaterMovieIdsProvider(token));
        }
        context.go('/watchlist');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentAuthState = ref.read(authProvider);

    if (currentAuthState.isAuthenticated &&
        currentAuthState.justLoggedIn &&
        !_messageShown &&
        (_previousAuthState == null || !_previousAuthState!.isAuthenticated)) {
      _showMessageFromFab();
      ref.read(authProvider.notifier).clearJustLoggedIn();
      _messageShown = true;
    }
    _previousAuthState = currentAuthState;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider);

    final location = GoRouterState.of(context).fullPath;
    if (location?.startsWith('/home') == true) {
      _selectedIndex = 0;
    } else if (location?.startsWith('/search') == true) {
      _selectedIndex = 1;
    } else if (location?.startsWith('/watchlist') == true) {
      _selectedIndex = 2;
    } else if (location?.startsWith('/profile') == true) {
      _selectedIndex = 3;
    }

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: widget.child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Watchlist',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              context.push('/chat');
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const CircleBorder(),
            child: Icon(
              Icons.smart_toy_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

// Navigation Extensions
extension AppRouterExtension on GoRouter {
  void goToLogin() => go('/login');
  void goToRegister() => go('/register');
  void goToHome() => go('/home');
  void goToSearch() => go('/search');
  void goToWatchlist() => go('/watchlist');
  void goToProfile() => go('/profile');
  void goToMoodDiscovery() => go('/mood-discovery');

  void goToMovieDetails(Movie movie, {String? from}) {
    if (from != null) {
      go('/$from/movie-details', extra: movie);
    } else {
      go('/movie/${movie.id}', extra: movie);
    }
  }

  void pushMovieDetails(Movie movie) {
    push('/movie/${movie.id}', extra: movie);
  }
}

// Helper class for navigation
class AppNavigation {
  static final GoRouter _router = AppRouter.router;

  static void toLogin() => _router.goToLogin();
  static void toRegister() => _router.goToRegister();
  static void toHome() => _router.goToHome();
  static void toSearch() => _router.goToSearch();
  static void toWatchlist() => _router.goToWatchlist();
  static void toProfile() => _router.goToProfile();
  static void toMoodDiscovery() => _router.goToMoodDiscovery();
  static void toMovieDetails(Movie movie) => _router.pushMovieDetails(movie);
  static void toMovieDetailsFromTab(Movie movie, String tab) {
    _router.goToMovieDetails(movie, from: tab);
  }
  static void back() => _router.pop();
  static void backToRoot() => _router.go('/home');
  static String get currentLocation =>
      _router.routerDelegate.currentConfiguration.fullPath;
  static bool get canPop => _router.canPop();
}