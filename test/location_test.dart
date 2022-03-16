import 'package:dbus/dbus.dart';
import 'package:geoclue/geoclue.dart';
import 'package:test/test.dart';

void main() {
  test('properties', () {
    final timestamp = DateTime(2013, 8, 3, 13, 59, 15, 1, 2);

    final location = GeoClueLocation(
      accuracy: 1.2,
      altitude: 2.3,
      description: 'geoclue.dart',
      heading: -3.4,
      latitude: 4.5,
      longitude: 5.6,
      speed: 6.7,
      timestamp: timestamp,
    );

    final properties = <String, DBusValue>{
      'Accuracy': const DBusDouble(1.2),
      'Altitude': const DBusDouble(2.3),
      'Description': const DBusString('geoclue.dart'),
      'Heading': const DBusDouble(-3.4),
      'Latitude': const DBusDouble(4.5),
      'Longitude': const DBusDouble(5.6),
      'Speed': const DBusDouble(6.7),
      'Timestamp': DBusStruct(
        [
          DBusUint64(timestamp.millisecondsSinceEpoch ~/ 1000),
          DBusUint64(timestamp.microsecondsSinceEpoch % 1000000),
        ],
      ),
    };

    expect(GeoClueLocation.fromProperties(properties), equals(location));
  });

  test('magic values', () {
    final location = GeoClueLocation.fromProperties(<String, DBusValue>{
      'Accuracy': const DBusDouble(1.2),
      'Altitude': const DBusDouble(-double.maxFinite), // unknown
      'Heading': const DBusDouble(-1.0), // unknown
      'Latitude': const DBusDouble(2.3),
      'Longitude': const DBusDouble(3.4),
      'Speed': const DBusDouble(-1.0), // unknown
    });

    expect(location.accuracy, equals(1.2));
    expect(location.altitude, isNull); // unknown
    expect(location.heading, isNull); // unknown
    expect(location.latitude, equals(2.3));
    expect(location.longitude, equals(3.4));
    expect(location.speed, isNull); // unknown
  });

  test('equality', () {
    const l1 = GeoClueLocation(accuracy: 1.2, latitude: 2.3, longitude: 3.4);
    const l2 = GeoClueLocation(accuracy: 1.2, latitude: 2.3, longitude: 3.4);
    const l3 = GeoClueLocation(accuracy: 5.6, latitude: 6.7, longitude: 7.8);

    expect(l1, equals(l1));
    expect(l1, equals(l2));
    expect(l1, isNot(equals(l3)));

    expect(l2, equals(l1));
    expect(l2, equals(l2));
    expect(l2, isNot(equals(l3)));

    expect(l3, isNot(equals(l1)));
    expect(l3, isNot(equals(l2)));
    expect(l3, equals(l3));

    expect(l1.hashCode, equals(l2.hashCode));
    expect(l1.hashCode, isNot(equals(l3.hashCode)));
    expect(l1.toString(), equals(l2.toString()));
    expect(l1.toString(), isNot(equals(l3.toString())));
  });
}
