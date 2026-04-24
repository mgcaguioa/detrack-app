import 'package:flutter_test/flutter_test.dart';
import 'package:detrack_app/data/models/target.dart';

void main() {
  group('Target', () {
    test('constructor assigns all fields', () {
      const target = Target(id: 'abc', targetLat: 14.5995, targetLng: 120.9842);
      expect(target.id, 'abc');
      expect(target.targetLat, 14.5995);
      expect(target.targetLng, 120.9842);
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'target-1',
        'targetLat': 14.5995,
        'targetLng': 120.9842,
      };
      final target = Target.fromJson(json);
      expect(target.id, 'target-1');
      expect(target.targetLat, 14.5995);
      expect(target.targetLng, 120.9842);
    });

    test('fromJson converts integer lat/lng to double', () {
      final json = {
        'id': 'target-2',
        'targetLat': 14,
        'targetLng': 121,
      };
      final target = Target.fromJson(json);
      expect(target.targetLat, isA<double>());
      expect(target.targetLng, isA<double>());
      expect(target.targetLat, 14.0);
      expect(target.targetLng, 121.0);
    });
  });
}
