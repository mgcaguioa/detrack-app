import 'package:flutter_test/flutter_test.dart';
import 'package:detrack_app/core/utils/haversine.dart';

void main() {
  group('haversineDistance', () {
    test('returns 0 for identical coordinates', () {
      final result = haversineDistance(14.5995, 120.9842, 14.5995, 120.9842);
      expect(result, 0.0);
    });

    test('London to Paris is approximately 343 km', () {
      // London: 51.5074, -0.1278 / Paris: 48.8566, 2.3522
      final result = haversineDistance(51.5074, -0.1278, 48.8566, 2.3522);
      expect(result, closeTo(343556, 500));
    });

    test('is symmetric — A→B equals B→A', () {
      final ab = haversineDistance(14.5995, 120.9842, 10.3157, 123.8854);
      final ba = haversineDistance(10.3157, 123.8854, 14.5995, 120.9842);
      expect(ab, closeTo(ba, 0.001));
    });

    test('handles north-south only movement (no longitude delta)', () {
      // ~1 degree of latitude ≈ 111,195 m
      final result = haversineDistance(0.0, 0.0, 1.0, 0.0);
      expect(result, closeTo(111195, 10));
    });

    test('handles negative coordinates correctly', () {
      final result = haversineDistance(-33.8688, 151.2093, -37.8136, 144.9631);
      expect(result, closeTo(714000, 2000)); // Sydney to Melbourne ~714 km
    });
  });
}
