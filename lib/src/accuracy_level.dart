import 'package:meta/meta.dart';

/// Used to specify level of accuracy requested by, or allowed for a client.
@immutable
class GeoClueAccuracyLevel {
  const GeoClueAccuracyLevel._(this.value, this.name);

  /// The value of the accuracy level.
  final int value;

  /// The name of the accuracy level.
  final String name;

  /// Accuracy level unknown or unset.
  static const none = GeoClueAccuracyLevel._(0, 'none');

  /// Country-level accuracy.
  static const country = GeoClueAccuracyLevel._(1, 'country');

  /// City-level accuracy.
  static const city = GeoClueAccuracyLevel._(4, 'city');

  /// Neighborhood-level accuracy.
  static const neighborhood = GeoClueAccuracyLevel._(5, 'neighborhood');

  /// Street-level accuracy.
  static const street = GeoClueAccuracyLevel._(6, 'street');

  /// Exact accuracy. Typically requires GPS receiver.
  static const exact = GeoClueAccuracyLevel._(8, 'exact');

  /// All available accuracy level values.
  static const levels = <GeoClueAccuracyLevel>[
    none,
    country,
    city,
    neighborhood,
    street,
    exact,
  ];

  /// Returns the level by [value].
  static GeoClueAccuracyLevel byValue(int value) {
    for (final level in levels) {
      if (level.value == value) return level;
    }
    throw ArgumentError.value(value, 'value', 'No level value with that value');
  }

  @override
  String toString() => 'GeoClueAccuracyLevel.$name';
}
