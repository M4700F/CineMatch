import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer
import '../widgets/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<IconData> _icons = [
    Icons.movie_filter,
    Icons.theaters,
    Icons.local_movies,
    Icons.videocam,
    Icons.camera_roll,
  ];
  int _currentIconIndex = 0;
  Timer? _iconChangeTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Repeat the animation back and forth

    _animation = Tween<double>(begin: -15.0, end: 15.0).animate(
      // Increased floating range
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _iconChangeTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // Changed to 2 seconds
      setState(() {
        _currentIconIndex = (_currentIconIndex + 1) % _icons.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconChangeTimer?.cancel(); // Cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation.value),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        child: Column(
                          key: ValueKey<int>(
                            _currentIconIndex,
                          ), // Key is important for AnimatedSwitcher
                          children: [
                            Icon(
                              _icons[_currentIconIndex],
                              size: 150, // Further increased size
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'CineMatch',
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    // Changed to displayMedium for even bigger text
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Loading indicator
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
