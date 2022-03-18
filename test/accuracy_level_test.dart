import 'package:geoclue/geoclue.dart';
import 'package:test/test.dart';

void main() {
  test('by value', () {
    for (final level in GeoClueAccuracyLevel.levels) {
      expect(level, equals(GeoClueAccuracyLevel.byValue(level.value)));
    }
  });

  test('unknown', () {
    expect(() => GeoClueAccuracyLevel.byValue(-1), throwsArgumentError);
  });
}
