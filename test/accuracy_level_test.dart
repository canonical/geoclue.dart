import 'package:geoclue/geoclue.dart';
import 'package:test/test.dart';

void main() {
  test('by value', () {
    for (final level in GeoClueAccuracyLevel.levels) {
      expect(level, same(GeoClueAccuracyLevel.byValue(level.value)));
    }
    expect(() => GeoClueAccuracyLevel.byValue(-1), throwsArgumentError);
  });

  test('switch case', () {
    for (final level in GeoClueAccuracyLevel.levels) {
      switch (level) {
        case GeoClueAccuracyLevel.none:
        case GeoClueAccuracyLevel.country:
        case GeoClueAccuracyLevel.city:
        case GeoClueAccuracyLevel.neighborhood:
        case GeoClueAccuracyLevel.street:
        case GeoClueAccuracyLevel.exact:
          break;
        default:
          throw UnsupportedError(level.toString());
      }
    }
  });
}
