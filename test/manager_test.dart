import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:geoclue/geoclue.dart';
import 'package:geoclue/src/constants.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'manager_test.mocks.dart';

@GenerateMocks([DBusClient, DBusPropertiesChangedSignal, DBusRemoteObject])
void main() {
  test('connect and disconnect', () async {
    final object = createMockRemoteObject();
    final bus = object.client as MockDBusClient;

    final manager = GeoClueManager(object: object);
    await manager.connect();
    verify(object.getAllProperties(kManager)).called(1);

    await manager.close();
    verify(bus.close()).called(1);
  });

  test('external bus', () async {
    final bus = MockDBusClient();
    final manager = GeoClueManager(bus: bus);
    await manager.close();
    verifyNever(bus.close());
  });

  test('get client', () async {
    final object = createMockRemoteObject();
    final manager = GeoClueManager(object: object);
    final client = await manager.getClient();
    expect(client.toString(), 'GeoClueClient(/Path/To/Client)');
    verify(object.callMethod(kManager, 'GetClient', [],
            replySignature: DBusSignature('o')))
        .called(1);
  });

  test('create client', () async {
    final object = createMockRemoteObject();
    final manager = GeoClueManager(object: object);
    final client = await manager.createClient();
    expect(client.toString(), 'GeoClueClient(/Created/Client)');
    verify(object.callMethod(kManager, 'CreateClient', [],
            replySignature: DBusSignature('o')))
        .called(1);
  });

  test('delete client', () async {
    final object = createMockRemoteObject();
    final manager = GeoClueManager(object: object);
    final client = await manager.createClient();
    await manager.deleteClient(client);
    verify(object.callMethod(
            kManager, 'DeleteClient', [DBusObjectPath('/Created/Client')],
            replySignature: DBusSignature('')))
        .called(1);
  });

  test('in use', () async {
    final controller = StreamController<DBusPropertiesChangedSignal>();
    final object = createMockRemoteObject(
      propertiesChanged: controller.stream,
      properties: {'InUse': const DBusBoolean(true)},
    );

    final manager = GeoClueManager(object: object);
    expect(manager.inUse, isFalse);

    // init
    await manager.connect();
    expect(manager.inUse, isTrue);

    // changed
    controller.add(createMockPropertiesChangedSignal(
      {'InUse': const DBusBoolean(false)},
    ));
    await expectLater(manager.propertiesChanged, emits(['InUse']));
    expect(manager.inUse, isFalse);
  });

  test('available accuracy level', () async {
    final controller = StreamController<DBusPropertiesChangedSignal>();
    final object = createMockRemoteObject(
      propertiesChanged: controller.stream,
      properties: {
        'AvailableAccuracyLevel': DBusUint32(GeoClueAccuracyLevel.city.value),
      },
    );

    final manager = GeoClueManager(object: object);
    expect(manager.availableAccuracyLevel, equals(GeoClueAccuracyLevel.none));

    // init
    await manager.connect();
    expect(manager.availableAccuracyLevel, equals(GeoClueAccuracyLevel.city));

    // changed
    controller.add(createMockPropertiesChangedSignal(
      {'AvailableAccuracyLevel': DBusUint32(GeoClueAccuracyLevel.street.value)},
    ));
    await expectLater(
        manager.propertiesChanged, emits(['AvailableAccuracyLevel']));
    expect(manager.availableAccuracyLevel, equals(GeoClueAccuracyLevel.street));
  });
}

MockDBusRemoteObject createMockRemoteObject({
  Stream<DBusPropertiesChangedSignal>? propertiesChanged,
  Map<String, DBusValue>? properties,
}) {
  final dbus = MockDBusClient();
  final object = MockDBusRemoteObject();
  when(object.client).thenReturn(dbus);
  when(object.propertiesChanged)
      .thenAnswer((_) => propertiesChanged ?? const Stream.empty());
  when(object.getAllProperties(kManager))
      .thenAnswer((_) async => properties ?? {});
  when(object.callMethod(
    kManager,
    'CreateClient',
    [],
    replySignature:
        argThat(equals(DBusSignature('o')), named: 'replySignature'),
  )).thenAnswer((_) async {
    return DBusMethodSuccessResponse([DBusObjectPath('/Created/Client')]);
  });
  when(object.callMethod(
    kManager,
    'GetClient',
    [],
    replySignature: DBusSignature('o'),
  )).thenAnswer((_) async =>
      DBusMethodSuccessResponse([DBusObjectPath('/Path/To/Client')]));
  when(object.callMethod(
    kManager,
    'DeleteClient',
    [DBusObjectPath('/Created/Client')],
    replySignature: argThat(equals(DBusSignature('')), named: 'replySignature'),
  )).thenAnswer((_) async => DBusMethodSuccessResponse());
  return object;
}

MockDBusPropertiesChangedSignal createMockPropertiesChangedSignal(
  Map<String, DBusValue> properties,
) {
  final signal = MockDBusPropertiesChangedSignal();
  when(signal.propertiesInterface).thenReturn(kManager);
  when(signal.changedProperties).thenReturn(properties);
  return signal;
}
