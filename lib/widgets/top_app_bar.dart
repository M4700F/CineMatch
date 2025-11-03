import 'package:flutter/material.dart';

class TopAppBarWidget extends StatelessWidget {
  final String title;
  final bool showSearch;
  final VoidCallback? onSearchClick;
  final List<Widget> extraActions;

  const TopAppBarWidget({
    super.key,
    required this.title,
    this.showSearch = true,
    this.onSearchClick,
    this.extraActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = <Widget>[];

    actions.addAll(extraActions);

    if (showSearch) {
      actions.add(
        IconButton(
          icon: Icon(
            Icons.search,
            color: isDark
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: onSearchClick,
          tooltip: 'Search',
        ),
      );
    }

    if (actions.isNotEmpty) {
      actions.add(const SizedBox(width: 8));
    }

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.movie_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ).createShader(bounds),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white, // This will be masked by the gradient
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      actions: actions.isEmpty ? null : actions,
    );
  }
}
