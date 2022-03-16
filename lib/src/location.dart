import 'package:dbus/dbus.dart';
import 'package:meta/meta.dart';

import 'util.dart';

/// This is the interface you use on location objects.
@immutable
class GeoClueLocation {
  /// Creates a new [GeoClueLocation].
  const GeoClueLocation({
    required this.accuracy,
    this.altitude,
    this.description,
    this.heading,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.timestamp,
  });

  /// Creates a new [GeoClueLocation] from a map of [values].
  factory GeoClueLocation.fromProperties(Map<String, DBusValue> values) {
    return GeoClueLocation(
      accuracy: values.get<double>('Accuracy')!,
      altitude: values.get<double>('Altitude').orNullIf(-double.maxFinite),
      description: values.get<String>('Description'),
      heading: values.get<double>('Heading').orNullIf(-1.0),
      latitude: values.get<double>('Latitude')!,
      longitude: values.get<double>('Longitude')!,
      speed: values.get<double>('Speed').orNullIf(-1.0),
      timestamp: values['Timestamp']?.toTimestamp(),
    );
  }

  /// The accuracy of the location fix, in meters.
  final double accuracy;

  /// The altitude of the location fix, in meters.
  final double? altitude;

  /// A human-readable description of the location, if available.
  ///
  /// **WARNING**: Applications should not rely on this property since not all
  /// sources provide a description. If you really need a description (or more
  /// details) about current location, use a reverse-geocoding API.
  final String? description;

  /// The heading direction in degrees with respect to North direction,
  /// in clockwise order.
  ///
  /// That means North becomes 0 degree, East: 90 degrees, South: 180 degrees,
  /// West: 270 degrees and so on.
  final double? heading;

  /// The latitude of the location, in degrees.
  final double latitude;

  /// The longitude of the location, in degrees.
  final double longitude;

  /// The speed in meters per second.
  final double? speed;

  /// The timestamp when the location was determined, if available.
  ///
  /// This is the time of measurement if the backend provided that information,
  /// otherwise the time when GeoClue received the new location.
  ///
  /// Note that GeoClue can't guarantee that the timestamp will always
  /// monotonically increase, as a backend may not respect that. Also note that
  /// a timestamp can be very old, e.g. because of a cached location.
  final DateTime? timestamp;

  @override
  String toString() {
    return 'GeoClueLocation(accuracy: $accuracy, altitude: $altitude, heading: $heading, latitude: $latitude, longitude: $longitude, speed: $speed, description: $description, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GeoClueLocation &&
        other.accuracy == accuracy &&
        other.altitude == altitude &&
        other.description == description &&
        other.heading == heading &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.speed == speed &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      accuracy,
      altitude,
      description,
      heading,
      latitude,
      longitude,
      speed,
      timestamp,
    );
  }
}
