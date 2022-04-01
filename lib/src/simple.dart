part of 'geoclue.dart';

/// Simplified convenience API
///
/// This class makes it straightforward to get the last known location, and to
/// monitor location updates. It takes care of creating and managing the
/// [GeoClueManager] and [GeoClueClient] instances.
///
/// See also:
///  * [GeoClueManager]
///  * [GeoClueClient]
class GeoClue {
  GeoClue._();

  /// Returns the last known location or waits for a location update if unknown.
  static Future<GeoClueLocation> getLocation({
    GeoClueManager? manager,
    String? desktopId,
    GeoClueAccuracyLevel? accuracyLevel,
    int? distanceThreshold,
    int? timeThreshold,
  }) async {
    final simple = _GeoClueSimple(manager);
    final client = await simple.start(
      desktopId: desktopId,
      accuracyLevel: accuracyLevel,
      distanceThreshold: distanceThreshold,
      timeThreshold: timeThreshold,
    );
    final location = client.location ?? await client.locationUpdated.first;
    await simple.stop(client);
    return location;
  }

  /// Returns a stream of location updates.
  static Stream<GeoClueLocation> getLocationUpdates({
    GeoClueManager? manager,
    String? desktopId,
    GeoClueAccuracyLevel? accuracyLevel,
    int? distanceThreshold,
    int? timeThreshold,
  }) async* {
    final simple = _GeoClueSimple(manager);
    final client = await simple.start(
      desktopId: desktopId,
      accuracyLevel: accuracyLevel,
      distanceThreshold: distanceThreshold,
      timeThreshold: timeThreshold,
    );
    yield* client.locationUpdated;
    await simple.stop(client);
  }
}

class _GeoClueSimple {
  _GeoClueSimple(GeoClueManager? manager)
      : _manager = manager ?? GeoClueManager();

  final GeoClueManager _manager;

  Future<GeoClueClient> start({
    required String? desktopId,
    required GeoClueAccuracyLevel? accuracyLevel,
    required int? distanceThreshold,
    required int? timeThreshold,
  }) async {
    await _manager.connect();
    final client = await _manager.getClient();
    if (desktopId != null) {
      await client.setDesktopId(desktopId);
    }
    if (accuracyLevel != null) {
      await client.setRequestedAccuracyLevel(accuracyLevel);
    }
    if (distanceThreshold != null) {
      await client.setDistanceThreshold(distanceThreshold);
    }
    if (timeThreshold != null) {
      await client.setTimeThreshold(timeThreshold);
    }
    await client.start();
    return client;
  }

  Future<void> stop(GeoClueClient client) async {
    await client.stop();
    await _manager.close();
  }
}
