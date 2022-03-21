import 'dart:async';

import 'package:geoclue/geoclue.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'simple_test.mocks.dart';

@GenerateMocks([GeoClueClient, GeoClueManager])
void main() {
  const l1 = GeoClueLocation(accuracy: 0.1, latitude: 1.2, longitude: 2.3);
  const l2 = GeoClueLocation(accuracy: 4.5, latitude: 5.6, longitude: 6.7);

  test('last known location', () async {
    final client = MockGeoClueClient();
    when(client.location).thenReturn(l1);

    final manager = MockGeoClueManager();
    when(manager.getClient()).thenAnswer((_) async => client);

    expect(await GeoClue.getLocation(manager: manager), l1);
    verify(manager.connect()).called(1);
    verify(manager.getClient()).called(1);
    verify(manager.close()).called(1);

    verify(client.start()).called(1);
    verify(client.stop()).called(1);
    verify(client.location).called(1);
    verifyNever(client.locationUpdated);
  });

  test('wait for location', () async {
    final client = MockGeoClueClient();
    when(client.location).thenReturn(null);
    when(client.locationUpdated).thenAnswer((_) => Stream.value(l1));

    final manager = MockGeoClueManager();
    when(manager.getClient()).thenAnswer((_) async => client);

    expect(await GeoClue.getLocation(manager: manager), l1);
    verify(manager.connect()).called(1);
    verify(manager.getClient()).called(1);
    verify(manager.close()).called(1);

    verify(client.start()).called(1);
    verify(client.stop()).called(1);
    verify(client.location).called(1);
    verify(client.locationUpdated).called(1);
  });

  test('location attributes', () async {
    final client = MockGeoClueClient();
    when(client.location).thenReturn(l1);

    final manager = MockGeoClueManager();
    when(manager.getClient()).thenAnswer((_) async => client);

    await GeoClue.getLocation(
      manager: manager,
      desktopId: 'desktop-id',
      accuracyLevel: GeoClueAccuracyLevel.city,
      distanceThreshold: 10,
      timeThreshold: 20,
    );
    verify(client.setDesktopId('desktop-id')).called(1);
    verify(client.setRequestedAccuracyLevel(GeoClueAccuracyLevel.city))
        .called(1);
    verify(client.setDistanceThreshold(10)).called(1);
    verify(client.setTimeThreshold(20)).called(1);
  });

  test('location updates', () async {
    final controller = StreamController<GeoClueLocation>();

    final client = MockGeoClueClient();
    when(client.locationUpdated).thenAnswer((_) => controller.stream);

    final manager = MockGeoClueManager();
    when(manager.getClient()).thenAnswer((_) async => client);

    final updates = GeoClue.getLocationUpdates(manager: manager);
    controller.add(l1);
    controller.add(l2);
    await expectLater(updates, emitsInOrder(<GeoClueLocation>[l1, l2]));

    await untilCalled(manager.close());
    verify(manager.close()).called(1);
    verify(client.stop()).called(1);
  });
}
