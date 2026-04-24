import 'package:flutter_test/flutter_test.dart';
import 'package:detrack_app/data/models/location_reading.dart';

void main() {
  group('LocationReading', () {
    test('constructor assigns all fields', () {
      final ts = DateTime(2024, 1, 1, 12, 0, 0);
      final reading = LocationReading(
        timestamp: ts,
        latitude: 14.5995,
        longitude: 120.9842,
        distance: 500.0,
      );
      expect(reading.timestamp, ts);
      expect(reading.latitude, 14.5995);
      expect(reading.longitude, 120.9842);
      expect(reading.distance, 500.0);
    });

    test('stores zero distance correctly', () {
      final reading = LocationReading(
        timestamp: DateTime(2024, 6, 1),
        latitude: 0.0,
        longitude: 0.0,
        distance: 0.0,
      );
      expect(reading.distance, 0.0);
      expect(reading.latitude, 0.0);
      expect(reading.longitude, 0.0);
    });
  });
}
