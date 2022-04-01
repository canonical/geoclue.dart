import 'dart:async';

import 'package:geoclue/geoclue.dart';

Future<void> main() async {
  final location = await GeoClue.getLocation(desktopId: '<desktop-id>');
  print('Current location: $location');

  print('Waiting 10s for location updates...');
  late StreamSubscription sub;
  sub = GeoClue.getLocationUpdates(desktopId: '<desktop-id>')
      .timeout(const Duration(seconds: 10), onTimeout: (_) => sub.cancel())
      .listen((location) {
    print('... $location');
  });
}
