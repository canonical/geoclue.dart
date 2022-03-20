/// [GeoClue](https://gitlab.freedesktop.org/geoclue/geoclue/-/wikis/home): The Geolocation Service
///
/// Geoclue is a D-Bus service that provides location information. It utilizes many
/// sources to best find user's location:
///
/// - WiFi-based geolocation via [Mozilla Location Service](https://wiki.mozilla.org/CloudServices/Location) (accuracy: in meters)
/// - GPS(A) receivers (accuracy: in centimeters)
/// - GPS of other devices on the local network, e.g smartphones (accuracy: in centimeters)
/// - 3G modems (accuracy: in kilometers, unless modem has GPS)
/// - GeoIP (accuracy: city-level)
///
/// ```dart
/// import 'package:geoclue/geoclue.dart';
///
/// Future<void> main() async {
///   final manager = GeoClueManager();
///   await manager.connect();
///
///   final client = await manager.getClient();
///   await client.setDesktopId('<desktop-id>');
///   await client.start();
///
///   print(await client.getLocation()); // "GeoClueLocation(..., latitude: 12.34, longitude: 56.78, ...)"
///
///   await manager.close();
/// }
/// ```
library geoclue;

export 'src/accuracy_level.dart';
export 'src/geoclue.dart';
export 'src/location.dart';
