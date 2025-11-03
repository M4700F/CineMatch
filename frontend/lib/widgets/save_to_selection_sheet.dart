import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../models/movie.dart'; // Import the Movie model
import '../providers/auth_provider.dart'; // Import AuthProvider
import '../services/watchlist_service.dart'; // Import WatchlistService

class SaveToSelectionSheet extends ConsumerStatefulWidget { // Change to ConsumerStatefulWidget
  final Movie movie; // Add movie parameter
  const SaveToSelectionSheet({super.key, required this.movie}); // Update constructor

  @override
  ConsumerState<SaveToSelectionSheet> createState() => _SaveToSelectionSheetState(); // Change to ConsumerState
}

class _SaveToSelectionSheetState extends ConsumerState<SaveToSelectionSheet> { // Change to ConsumerState
  String? _selectedOption; // To hold the selected option: 'favorites' or 'watch_later'
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text('Save To', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          RadioListTile<String>(
            title: const Text('Favorites'),
            value: 'favorites',
            groupValue: _selectedOption,
            onChanged: _isSaving ? null : (value) {
              setState(() {
                _selectedOption = value;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Watch later'),
            value: 'watch_later',
            groupValue: _selectedOption,
            onChanged: _isSaving ? null : (value) {
              setState(() {
                _selectedOption = value;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : () {
                // Functionality for "New Collection" will be added later if requested
              },
              icon: const Icon(Icons.add),
              label: const Text('New Collection'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving || _selectedOption == null ? null : () async {
                setState(() {
                  _isSaving = true;
                });
                final token = ref.read(authTokenProvider);
                final userId = ref.read(currentUserProvider)?.id;
                final movieId = widget.movie.id.toString();

                if (token == null || userId == null) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('User not authenticated.'),
                      backgroundColor: cs.error,
                    ),
                  );
                  Navigator.pop(context, null);
                  return;
                }

                try {
                  if (_selectedOption == 'favorites') {
                    await WatchlistService.addMovieToFavorites(
                      token: token,
                      userId: userId,
                      movieId: movieId,
                    );
                  } else if (_selectedOption == 'watch_later') {
                    await WatchlistService.addMovieToWatchLater(
                      token: token,
                      userId: userId,
                      movieId: movieId,
                    );
                  }
                  if (!mounted) return;
                  Navigator.pop(context, _selectedOption); // Pass the selected option back
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save movie: $e'),
                      backgroundColor: cs.error,
                    ),
                  );
                  Navigator.pop(context, null); // Pop on error
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSaving = false;
                    });
                  }
                }
              },
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Done'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
