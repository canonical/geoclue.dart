# GeoClue for Dart

[GeoClue](https://gitlab.freedesktop.org/geoclue/geoclue/-/wikis/home): The Geolocation Service

```dart
import 'package:geoclue/geoclue.dart';

Future<void> main() async {
  final manager = GeoClueManager();
  await manager.connect();

  final client = await manager.getClient();
  await client.start('geoclue.dart');

  print(await client.getLocation()); // "GeoClueLocation(..., latitude: 12.34, longitude: 56.78, ...)"

  await manager.close();
}
```

## Contributing to geoclue.dart

We welcome contributions! See the [contribution guide](CONTRIBUTING.md) for more details.
