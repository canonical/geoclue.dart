# GeoClue for Dart

[![CI](https://github.com/jpnurmi/geoclue.dart/workflows/Tests/badge.svg)](https://github.com/jpnurmi/geoclue.dart/actions/workflows/tests.yaml)
[![codecov](https://codecov.io/gh/jpnurmi/geoclue.dart/branch/main/graph/badge.svg?token=4GfsNIhvdS)](https://codecov.io/gh/jpnurmi/geoclue.dart)

[GeoClue](https://gitlab.freedesktop.org/geoclue/geoclue/-/wikis/home): The Geolocation Service

Geoclue is a D-Bus service that provides location information. It utilizes many
sources to best find user's location:

- WiFi-based geolocation via [Mozilla Location Service](https://wiki.mozilla.org/CloudServices/Location) (accuracy: in meters)
- GPS(A) receivers (accuracy: in centimeters)
- GPS of other devices on the local network, e.g smartphones (accuracy: in centimeters)
- 3G modems (accuracy: in kilometers, unless modem has GPS)
- GeoIP (accuracy: city-level)


```dart
import 'package:geoclue/geoclue.dart';

Future<void> main() async {
  final manager = GeoClueManager();
  await manager.connect();

  final client = await manager.getClient();
  await client.setDesktopId('<desktop-id>');
  await client.start();

  print(await client.getLocation()); // "GeoClueLocation(..., latitude: 12.34, longitude: 56.78, ...)"

  await manager.close();
}
```

## Contributing to geoclue.dart

We welcome contributions! See the [contribution guide](CONTRIBUTING.md) for more details.
