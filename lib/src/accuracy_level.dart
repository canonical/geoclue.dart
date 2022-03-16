/// Used to specify level of accuracy requested by, or allowed for a client.
enum GeoClueAccuracyLevel {
  /// Accuracy level unknown or unset.
  none,

  /// Country-level accuracy.
  country,

  /// City-level accuracy.
  city,

  /// neighborhood-level accuracy.
  neighborhood,

  /// Street-level accuracy.
  street,

  /// Exact accuracy. Typically requires GPS receiver.
  exact,
}
