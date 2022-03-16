import 'package:geoclue/geoclue.dart';

Future<void> main() async {
  final manager = GeoClueManager();
  await manager.connect();

  final client = await manager.getClient();
  await client.start('geoclue.dart');

  print(await client.getLocation());

  await manager.close();
}
