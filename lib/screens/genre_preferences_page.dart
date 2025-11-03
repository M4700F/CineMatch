import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/language_provider.dart';
import '../providers/recommendation_provider.dart';
import '../services/movie_api_service.dart';
import '../utils/app_localizations.dart';
import '../widgets/gradient_background.dart';

class GenrePreferencesPage extends ConsumerWidget {
  const GenrePreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(genrePreferencesProvider);
    final notifier = ref.read(genrePreferencesProvider.notifier);
    final localizations = ref.watch(localizationProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(localizations.personalizeRecommendations),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            children: [
              Text(
                localizations.adjustGenrePreferences,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                localizations.preferencesInstruction,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (state.hasCompleted)
                Row(
                  children: [
                    Icon(Icons.check_circle, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      localizations.preferencesSaved,
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              ..._genreOptions.map((option) {
                final value = state.preferences.valueFor(option.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _GenreSliderCard(
                    option: option,
                    value: value,
                    enabled: !state.isSubmitting,
                    onChanged: (updated) =>
                        notifier.updatePreference(option.key, updated),
                    localizations: localizations,
                  ),
                );
              }),
              if (state.recommendations.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  localizations.forYou,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 230,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 16),
                    itemBuilder: (context, index) {
                      final movie = state.recommendations[index];
                      final posterUrl = MovieApiService.getMoviePosterUrl(
                        movie,
                      );
                      return SizedBox(
                        width: 140,
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
                                        color: colorScheme.surfaceVariant,
                                        child: Icon(
                                          Icons.movie_outlined,
                                          color: colorScheme.onSurfaceVariant,
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
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemCount: state.recommendations.length,
                  ),
                ),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.error != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: TextStyle(color: colorScheme.onErrorContainer),
                        ),
                      ),
                      IconButton(
                        onPressed: () => notifier.clearError(),
                        icon: Icon(
                          Icons.close,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : notifier.resetPreferences,
                      child: Text(localizations.resetToDefaults),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: state.isSubmitting
                          ? null
                          : () => notifier.submitPreferences(),
                      icon: state.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_fix_high),
                      label: Text(
                        state.isSubmitting
                            ? localizations.fetchingRecommendations
                            : localizations.submitPreferences,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreSliderCard extends StatelessWidget {
  final _GenreOption option;
  final double value;
  final ValueChanged<double> onChanged;
  final AppLocalizations localizations;
  final bool enabled;

  const _GenreSliderCard({
    required this.option,
    required this.value,
    required this.onChanged,
    required this.localizations,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = Color.lerp(
      colorScheme.surfaceVariant,
      colorScheme.primary.withOpacity(0.1),
      (value / 2).clamp(0.0, 1.0),
    );

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(option.icon, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.label(localizations),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(color: colorScheme.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value.clamp(0.5, 5.0),
            min: 0.5,
            max: 5.0,
            divisions: 9,
            onChanged: enabled ? onChanged : null,
          ),
          const SizedBox(height: 4),
          Text(
            _preferenceLabel(value),
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _preferenceLabel(double value) {
    if (value <= 0.75) return 'Not for me';
    if (value <= 1.5) return 'Low interest';
    if (value <= 2.5) return 'Open to explore';
    if (value <= 3.5) return 'I enjoy this';
    return 'Love this genre';
  }
}

class _GenreOption {
  final String key;
  final IconData icon;
  final String Function(AppLocalizations) label;

  _GenreOption(this.key, this.icon, this.label);
}

final List<_GenreOption> _genreOptions = [
  _GenreOption('action', Icons.local_fire_department_rounded, (l) => l.action),
  _GenreOption('adventure', Icons.explore_rounded, (l) => l.adventure),
  _GenreOption('animation', Icons.color_lens_rounded, (l) => l.animation),
  _GenreOption('childrens', Icons.child_care_rounded, (l) => l.childrens),
  _GenreOption(
    'comedy',
    Icons.sentiment_satisfied_alt_rounded,
    (l) => l.comedy,
  ),
  _GenreOption('crime', Icons.policy_rounded, (l) => l.crime),
  _GenreOption('documentary', Icons.menu_book_rounded, (l) => l.documentary),
  _GenreOption('drama', Icons.theater_comedy_rounded, (l) => l.drama),
  _GenreOption('fantasy', Icons.auto_awesome_rounded, (l) => l.fantasy),
  _GenreOption('horror', Icons.nightlight_round, (l) => l.horror),
  _GenreOption('mystery', Icons.psychology_alt_rounded, (l) => l.mystery),
  _GenreOption('romance', Icons.favorite_rounded, (l) => l.romance),
  _GenreOption('scifi', Icons.science_rounded, (l) => l.sciFi),
  _GenreOption('thriller', Icons.bolt_rounded, (l) => l.thriller),
];
