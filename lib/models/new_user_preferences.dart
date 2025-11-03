import 'dart:collection';

/// Represents the genre preference payload required by the backend when
/// requesting recommendations for new users.
class NewUserPreferences {
  static const List<String> genreKeys = [
    'action',
    'adventure',
    'animation',
    'childrens',
    'comedy',
    'crime',
    'documentary',
    'drama',
    'fantasy',
    'horror',
    'mystery',
    'romance',
    'scifi',
    'thriller',
  ];

  final Map<String, double> _values;

  NewUserPreferences({Map<String, double>? values})
    : _values = {
        for (final key in genreKeys)
          key: values != null && values[key] != null
              ? values[key]!.clamp(0.5, 5.0).toDouble()
              : 1.0,
      };

  factory NewUserPreferences.fromJson(Map<String, dynamic> json) {
    final mapped = <String, double>{};
    for (final key in genreKeys) {
      final raw = json[key];
      mapped[key] = raw is num ? raw.toDouble() : 1.0;
    }
    return NewUserPreferences(values: mapped);
  }

  Map<String, double> toJson() {
    return Map<String, double>.from(_values);
  }

  Map<String, double> get values => UnmodifiableMapView(_values);

  double valueFor(String key) => _values[key] ?? 1.0;

  NewUserPreferences update(String key, double value) {
    if (!genreKeys.contains(key)) {
      return this;
    }
    final next = Map<String, double>.from(_values);
    next[key] = value.clamp(0.5, 5.0);
    return NewUserPreferences(values: next);
  }

  NewUserPreferences reset() => NewUserPreferences();

  bool get isDefault {
    for (final entry in _values.entries) {
      if ((entry.value - 1.0).abs() > 0.0001) {
        return false;
      }
    }
    return true;
  }
}
