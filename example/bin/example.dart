import 'package:geoclue/geoclue.dart';

Future<void> main() async {
  final manager = GeoClueManager();
  await manager.connect();

  final client = await manager.getClient();
  await client.setDesktopId('<desktop-id>');
  await client.setRequestedAccuracyLevel(GeoClueAccuracyLevel.exact);
  await client.start();

  print('Available accuracy: ${manager.availableAccuracyLevel.name}');
  print('Requested accuracy: ${client.requestedAccuracyLevel.name}');
  print('Last known location: ${client.location ?? 'unknown'}');
  print('Waiting 10s for location updates...');
  client.locationUpdated
      .timeout(const Duration(seconds: 10), onTimeout: (_) => manager.close())
      .listen((location) {
    print('... $location');
  });
}
