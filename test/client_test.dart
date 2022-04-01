import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:geoclue/geoclue.dart';
import 'package:geoclue/src/constants.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'client_test.mocks.dart';

@GenerateMocks([DBusClient, DBusPropertiesChangedSignal, DBusRemoteObject])
void main() {
  test('start and stop', () async {
    final object = createMockRemoteObject();

    final client = GeoClueClient(object);
    await client.start();
    verifyInOrder([
      object.callMethod(kClient, 'Start', [],
          replySignature: DBusSignature('')),
      object.getAllProperties(kClient),
    ]);

    await client.stop();
    verify(object.callMethod(kClient, 'Stop', [],
            replySignature: DBusSignature('')))
        .called(1);
  });

  test('null initial location', () async {
    final object = createMockRemoteObject();

    final client = GeoClueClient(object);
    expect(client.location, isNull);
  });

  test('unknown location', () async {
    final controller = StreamController<DBusPropertiesChangedSignal>();
    final object = createMockRemoteObject(
      propertiesChanged: controller.stream,
      properties: {'Location': DBusObjectPath('/')},
    );

    final client = GeoClueClient(object);
    await client.start();

    expect(client.location, isNull);
  });

  test('location', () async {
    final controller = StreamController<DBusPropertiesChangedSignal>();
    final object = createMockRemoteObject(
      propertiesChanged: controller.stream,
      properties: {
        'Active': const DBusBoolean(true),
        'Location': DBusObjectPath('/Path/To/Location/1'),
      },
      locations: {
        DBusObjectPath('/Path/To/Location/1'): <String, DBusValue>{
          'Accuracy': const DBusDouble(0.1),
          'Latitude': const DBusDouble(1.2),
          'Longitude': const DBusDouble(2.3),
        },
        DBusObjectPath('/Path/To/Location/2'): <String, DBusValue>{
          'Accuracy': const DBusDouble(4.5),
          'Latitude': const DBusDouble(5.6),
          'Longitude': const DBusDouble(6.7),
        },
      },
    );

    final client = GeoClueClient(object);
    await client.start();

    // init
    const l1 = GeoClueLocation(accuracy: 0.1, latitude: 1.2, longitude: 2.3);
    expect(client.location, equals(l1));

    // changed
    const l2 = GeoClueLocation(accuracy: 4.5, latitude: 5.6, longitude: 6.7);
    controller.add(createMockPropertiesChangedSignal(
      {'Location': DBusObjectPath('/Path/To/Location/2')},
    ));
    client.locationUpdated.listen(
      expectAsync1((value) => expect(value, equals(l2)), count: 1),
    );
    await expectLater(client.propertiesChanged, emits(['Location']));
    expect(client.location, equals(l2));
  });

  test('is active', () async {
    final controller = StreamController<DBusPropertiesChangedSignal>();
    final object = createMockRemoteObject(
      propertiesChanged: controller.stream,
      properties: {'Active': const DBusBoolean(true)},
    );

    final client = GeoClueClient(object);
    expect(client.active, isFalse);

    // init
    await client.start();
    expect(client.active, isTrue);

    // changed
    controller.add(createMockPropertiesChangedSignal(
      {'Active': const DBusBoolean(false)},
    ));
    await expectLater(client.propertiesChanged, emits(['Active']));
    expect(client.active, isFalse);
  });

  test('desktop id', () async {
    final controller = StreamController<DBusPropertiesChangedSignal>();
    final object = createMockRemoteObject(
      propertiesChanged: controller.stream,
      properties: {'DesktopId': const DBusString('client_test')},
    );

    final client = GeoClueClient(object);
    expect(client.desktopId, isEmpty);

    // init
    await client.start();
    expect(client.desktopId, equals('client_test'));

    // changed
    controller.add(createMockPropertiesChangedSignal(
      {'DesktopId': const DBusString('client_test_changed')},
    ));
    await expectLater(client.propertiesChanged, emits(['DesktopId']));
    expect(client.desktopId, equals('client_test_changed'));

    // set
    await client.setDesktopId('set_client_test');
    verify(object.setProperty(
      kClient,
      'DesktopId',
      const DBusString('set_client_test'),
    )).called(1);
  });

  test('distance threshold', () async {
    final controller = StreamController<DBusPropertiesChangedSignal>();
    final object = createMockRemoteObject(
      propertiesChanged: controller.stream,
      properties: {'DistanceThreshold': const DBusUint32(12)},
    );

    final client = GeoClueClient(object);
    expect(client.distanceThreshold, isZero);

    // init
    await client.start();
    expect(client.distanceThreshold, equals(12));

    // changed
    controller.add(createMockPropertiesChangedSignal(
      {'DistanceThreshold': const DBusUint32(34)},
    ));
    await expectLater(client.propertiesChanged, emits(['DistanceThreshold']));
    expect(client.distanceThreshold, equals(34));

    // set
    await client.setDistanceThreshold(56);
    verify(
      object.setProperty(kClient, 'DistanceThreshold', const DBusUint32(56)),
    ).called(1);
  });

  test('requested accuracy level', () async {
    final controller = StreamController<DBusPropertiesChangedSignal>();
    final object = createMockRemoteObject(
      propertiesChanged: controller.stream,
      properties: {
        'RequestedAccuracyLevel': DBusUint32(GeoClueAccuracyLevel.city.value),
      },
    );

    final client = GeoClueClient(object);
    expect(client.requestedAccuracyLevel, equals(GeoClueAccuracyLevel.none));

    // init
    await client.start();
    expect(client.requestedAccuracyLevel, equals(GeoClueAccuracyLevel.city));

    // changed
    controller.add(createMockPropertiesChangedSignal(
      {'RequestedAccuracyLevel': DBusUint32(GeoClueAccuracyLevel.street.value)},
    ));
    await expectLater(
        client.propertiesChanged, emits(['RequestedAccuracyLevel']));
    expect(client.requestedAccuracyLevel, equals(GeoClueAccuracyLevel.street));

    // set
    await client.setRequestedAccuracyLevel(GeoClueAccuracyLevel.exact);
    verify(
      object.setProperty(
        kClient,
        'RequestedAccuracyLevel',
        DBusUint32(GeoClueAccuracyLevel.exact.value),
      ),
    ).called(1);
  });

  test('time threshold', () async {
    final controller = StreamController<DBusPropertiesChangedSignal>();

    final object = createMockRemoteObject(
      propertiesChanged: controller.stream,
      properties: {'TimeThreshold': const DBusUint32(12)},
    );

    final client = GeoClueClient(object);
    expect(client.timeThreshold, isZero);

    // init
    await client.start();
    expect(client.timeThreshold, equals(12));

    // changed
    controller.add(createMockPropertiesChangedSignal(
      {'TimeThreshold': const DBusUint32(34)},
    ));
    await expectLater(client.propertiesChanged, emits(['TimeThreshold']));
    expect(client.timeThreshold, equals(34));

    // set
    await client.setTimeThreshold(56);
    verify(
      object.setProperty(kClient, 'TimeThreshold', const DBusUint32(56)),
    ).called(1);
  });
}

MockDBusRemoteObject createMockRemoteObject({
  Stream<DBusPropertiesChangedSignal>? propertiesChanged,
  Map<String, DBusValue>? properties,
  DBusMethodSuccessResponse? startResponse,
  DBusMethodSuccessResponse? stopResponse,
  Map<DBusObjectPath, Map<String, DBusValue>>? locations,
}) {
  final dbus = MockDBusClient();
  if (locations != null) {
    when(dbus.callMethod(
      destination: kBus,
      path: anyNamed('path'),
      interface: 'org.freedesktop.DBus.Properties',
      name: 'GetAll',
      values: [const DBusString(kLocation)],
      replySignature: anyNamed('replySignature'),
    )).thenAnswer((invocation) async {
      final path =
          invocation.namedArguments[const Symbol('path')] as DBusObjectPath;
      return DBusMethodSuccessResponse(
          [DBusDict.stringVariant(locations[path]!)]);
    });
  }

  final object = MockDBusRemoteObject();
  when(object.client).thenReturn(dbus);
  when(object.propertiesChanged)
      .thenAnswer((_) => propertiesChanged ?? const Stream.empty());
  when(object.getAllProperties(kClient))
      .thenAnswer((_) async => properties ?? {});
  when(object.callMethod(
    kClient,
    'Start',
    [],
    replySignature: DBusSignature(''),
  )).thenAnswer((_) async => startResponse ?? DBusMethodSuccessResponse());
  when(object.callMethod(
    kClient,
    'Stop',
    [],
    replySignature: DBusSignature(''),
  )).thenAnswer((_) async => stopResponse ?? DBusMethodSuccessResponse());
  return object;
}

MockDBusPropertiesChangedSignal createMockPropertiesChangedSignal(
  Map<String, DBusValue> properties,
) {
  final signal = MockDBusPropertiesChangedSignal();
  when(signal.propertiesInterface).thenReturn(kClient);
  when(signal.changedProperties).thenReturn(properties);
  return signal;
}
