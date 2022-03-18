import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:meta/meta.dart';

import 'accuracy_level.dart';
import 'client.dart';
import 'geoclue.dart';
import 'util.dart';

/// The GeoClue service manager
class GeoClueManager {
  /// Creates a new GeoClueManager connected to the system D-Bus.
  GeoClueManager({DBusClient? bus, @visibleForTesting DBusRemoteObject? object})
      : _bus = bus,
        _object = object ?? _createRemoteObject(bus);

  static DBusRemoteObject _createRemoteObject(DBusClient? bus) {
    return DBusRemoteObject(
      bus ?? DBusClient.system(),
      name: kBus,
      path: DBusObjectPath('/org/freedesktop/GeoClue2/Manager'),
    );
  }

  final DBusClient? _bus;
  final DBusRemoteObject _object;
  final _properties = <String, DBusValue>{};
  final _propertyController = StreamController<List<String>>.broadcast();
  final _clients = <GeoClueClient, DBusObjectPath>{};
  StreamSubscription? _propertySubscription;

  /// Whether service is currently is use by any application.
  bool get inUse => _getProperty('InUse', false);

  /// The level of available accuracy.
  GeoClueAccuracyLevel get availableAccuracyLevel =>
      GeoClueAccuracyLevel.values[_getProperty('AvailableAccuracyLevel', 0)];

  /// Connects to the GeoClue service.
  Future<void> connect() {
    _propertySubscription ??= _object.propertiesChanged.listen((signal) {
      if (signal.propertiesInterface == kManager) {
        _updateProperties(signal.changedProperties);
      }
    });
    return _object.getAllProperties(kManager).then(_updateProperties);
  }

  /// Closes connection to the GeoClue service.
  Future<void> close() async {
    await _propertySubscription?.cancel();
    _propertySubscription = null;
    if (_bus == null) {
      await _object.client.close();
    }
  }

  /// Gets a client object.
  ///
  /// On the first call, this method will create the client object but
  /// subsequent calls will return the existing client.
  Future<GeoClueClient> getClient() {
    return _object
        .callMethod(kManager, 'GetClient', [],
            replySignature: DBusSignature('o'))
        .then((response) =>
            _buildClient(response.values.first as DBusObjectPath));
  }

  /// Creates and retrieves a client object.
  ///
  /// Unlike [getClient], this method always creates a new client.
  Future<GeoClueClient> createClient() {
    return _object
        .callMethod(kManager, 'CreateClient', [],
            replySignature: DBusSignature('o'))
        .then((response) =>
            _buildClient(response.values.first as DBusObjectPath));
  }

  GeoClueClient _buildClient(DBusObjectPath path) {
    final client = GeoClueClient(
      DBusRemoteObject(_object.client, name: kBus, path: path),
    );
    _clients[client] = path;
    return client;
  }

  /// Use this method to explicitly destroy a client, created using [getClient]
  /// or [createClient].
  ///
  /// Long-running applications, should either use this to delete associated
  /// client(s) when not needed, or disconnect from the D-Bus connection used
  /// for communicating with Geoclue (which is implicit on client process
  /// termination).
  Future<void> deleteClient(GeoClueClient client) {
    final path = _clients.remove(client);
    assert(path != null);
    return _object.callMethod(kManager, 'DeleteClient', [path!],
        replySignature: DBusSignature(''));
  }

  /// Stream of property names as they change.
  Stream<List<String>> get propertiesChanged => _propertyController.stream;

  T _getProperty<T>(String name, T defaultValue) {
    return _properties.get(name) ?? defaultValue;
  }

  void _updateProperties(Map<String, DBusValue> properties) {
    _properties.addAll(properties);
    _propertyController.add(properties.keys.toList());
  }

  @override
  String toString() => 'GeoClueManager(${_object.path.value})';
}
