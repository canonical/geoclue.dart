import 'dart:async';

import 'package:dbus/dbus.dart';

import 'accuracy_level.dart';
import 'geoclue.dart';
import 'location.dart';
import 'util.dart';

/// A client to retrieve location information and receive location update events
/// from the GeoClue service.
class GeoClueClient {
  /// @internal
  GeoClueClient(this._object);

  final DBusRemoteObject _object;
  final _properties = <String, DBusValue>{};
  final _propertyController = StreamController<List<String>>.broadcast();
  final _locationController = StreamController<GeoClueLocation>.broadcast();
  StreamSubscription? _propertySubscription;

  /// Start receiving events about the current location.
  ///
  /// This method throws a [DBusAccessDeniedException] if the geoclue daemon
  /// can't determine the desktop ID of the calling app. In this case use
  /// [setDesktopId] to set this before using.
  Future<void> start() {
    _propertySubscription ??= _object.propertiesChanged.listen((signal) {
      if (signal.propertiesInterface == kClient) {
        _updateProperties(signal.changedProperties);
      }
    });
    return _object
        .callMethod(kClient, 'Start', [], replySignature: DBusSignature(''))
        .then((_) => _object.getAllProperties(kClient))
        .then(_updateProperties);
  }

  /// Stop receiving events about the current location.
  Future<void> stop() async {
    await _propertySubscription?.cancel();
    _propertySubscription = null;
    await _object.callMethod(kClient, 'Stop', [],
        replySignature: DBusSignature(''));
  }

  /// Whether the client is currently active.
  ///
  /// An active client was successfully started using [start] and is receiving
  /// location updates.
  ///
  /// Please keep in mind that geoclue can at any time stop and start the client
  /// on user (agent) request. Applications that are interested in in these
  /// changes, should watch for changes in this property.
  bool get isActive => _getProperty('Active', false);

  /// Returns the current location.
  ///
  /// Please note that this property will be set to "/" (D-Bus equivalent of
  /// null) initially, until Geoclue finds user's location.
  /// You want to delay reading this property until your callback to
  /// "LocationUpdated" signal is called for the first time after starting the
  /// client.
  Future<GeoClueLocation> getLocation() {
    assert(isActive, 'GeoClueClient.start() must be called first.');
    return _buildLocation(_properties['Location'] as DBusObjectPath);
  }

  /// A stream of location updates.
  ///
  /// The client should set the [distanceThreshold] property to control how
  /// often this signal is emitted.
  Stream<GeoClueLocation> get locationUpdated => _locationController.stream;

  /// The desktop file ID (the basename of the desktop file).
  ///
  /// This property must be set by applications for authorization to work.
  String get desktopId => _getProperty('DesktopId', '');

  /// The current distance threshold in meters.
  ///
  /// This value is used by the service when it gets new location info. If the
  /// distance moved is below the threshold, it won't emit a [locationUpdated]
  /// event.
  ///
  /// The default value is 0. When [timeThreshold] is zero, it always emits the
  /// signal.
  int get distanceThreshold => _getProperty('DistanceThreshold', 0);

  /// The level of accuracy requested by the client.
  ///
  /// Please keep in mind that the actual accuracy of location information is
  /// dependent on available hardware on your machine, external resources and/or
  /// how much accuracy user agrees to be confortable with.
  GeoClueAccuracyLevel get requestedAccuracyLevel =>
      GeoClueAccuracyLevel.values[_getProperty('RequestedAccuracyLevel', 0)];

  /// The current time threshold in seconds.
  ///
  /// This value is used by the service when it gets new location info. If the
  /// time since the last update is below the threshold, it won't emit a
  /// [locationUpdated] event.
  ///
  /// The default value is 0. When [timeThreshold] is zero, it always emits the
  /// signal.
  int get timeThreshold => _getProperty('TimeThreshold', 0);

  /// Sets the desktop ID.
  Future<void> setDesktopId(String id) {
    return _setProperty('DesktopId', DBusString(id));
  }

  /// Sets the distance threshold.
  Future<void> setDistanceThreshold(int threshold) {
    return _setProperty('DistanceThreshold', DBusUint32(threshold));
  }

  /// Sets the requested accuracy level.
  Future<void> setRequestedAccuracyLevel(GeoClueAccuracyLevel level) {
    return _setProperty('RequestedAccuracyLevel', DBusUint32(level.index));
  }

  /// Sets the time threshold.
  Future<void> setTimeThreshold(int threshold) {
    return _setProperty('TimeThreshold', DBusUint32(threshold));
  }

  /// Stream of property names as they change.
  Stream<List<String>> get propertiesChanged => _propertyController.stream;

  Future<GeoClueLocation> _buildLocation(DBusObjectPath path) async {
    final object = DBusRemoteObject(_object.client, name: kBus, path: path);
    final properties = await object.getAllProperties(kLocation);
    return GeoClueLocation.fromProperties(properties);
  }

  T _getProperty<T>(String name, T defaultValue) {
    return _properties.get(name) ?? defaultValue;
  }

  Future<void> _setProperty(String key, DBusValue value) {
    return _object.setProperty(kClient, key, value);
  }

  Future<void> _updateProperties(Map<String, DBusValue> properties) async {
    _properties.addAll(properties);
    _propertyController.add(properties.keys.toList());

    final location = properties['Location'] as DBusObjectPath?;
    if (location != null) {
      return _buildLocation(location).then(_locationController.add);
    }
  }

  @override
  String toString() => 'GeoClueClient(${_object.path.value})';
}
