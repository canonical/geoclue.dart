import 'package:geoclue/geoclue.dart';

Future<void> main() async {
  final manager = GeoClueManager();
  await manager.connect();

  final client = await manager.getClient();
  await client.setDesktopId('<desktop-id>');
  await client.start();

  print(await client.getLocation());

  await manager.close();
}
