import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

import 'package:detrack_app/core/utils/haversine.dart';
import 'package:detrack_app/data/models/target.dart';
import 'package:detrack_app/data/repositories/tracking_repository.dart';
import 'package:detrack_app/data/sources/location_service.dart';
import 'package:detrack_app/data/sources/mock_api_service.dart';

class MockLocationService extends Mock implements LocationService {}

class MockApiServiceFake extends Mock implements MockApiService {}

const _testTarget = Target(id: 'test', targetLat: 14.5995, targetLng: 120.9842);

Position _makePosition({double lat = 14.6000, double lng = 120.9900}) {
  return Position(
    latitude: lat,
    longitude: lng,
    timestamp: DateTime(2024),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

void main() {
  late MockLocationService mockLocationService;
  late MockApiServiceFake mockApiService;
  late TrackingRepository repo;

  setUp(() {
    mockLocationService = MockLocationService();
    mockApiService = MockApiServiceFake();
    repo = TrackingRepository(
      locationService: mockLocationService,
      apiService: mockApiService,
    );
  });

  group('TrackingRepository', () {
    test('requestPermission delegates to LocationService', () async {
      when(() => mockLocationService.requestPermission())
          .thenAnswer((_) async => true);

      final result = await repo.requestPermission();

      expect(result, isTrue);
      verify(() => mockLocationService.requestPermission()).called(1);
    });

    test('getTarget delegates to MockApiService', () async {
      when(() => mockApiService.fetchTarget())
          .thenAnswer((_) async => _testTarget);

      final result = await repo.getTarget();

      expect(result.id, 'test');
      verify(() => mockApiService.fetchTarget()).called(1);
    });

    test('getLocation delegates to LocationService', () async {
      final position = _makePosition();
      when(() => mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => position);

      final result = await repo.getLocation();

      expect(result.latitude, position.latitude);
      verify(() => mockLocationService.getCurrentLocation()).called(1);
    });

    group('buildReading', () {
      test('assigns latitude and longitude from position', () {
        final position = _makePosition(lat: 14.6000, lng: 120.9900);
        final reading = repo.buildReading(position, _testTarget);

        expect(reading.latitude, 14.6000);
        expect(reading.longitude, 120.9900);
      });

      test('distance matches haversineDistance', () {
        final position = _makePosition(lat: 14.6000, lng: 120.9900);
        final reading = repo.buildReading(position, _testTarget);

        final expected = haversineDistance(
          14.6000,
          120.9900,
          _testTarget.targetLat,
          _testTarget.targetLng,
        );

        expect(reading.distance, closeTo(expected, 0.001));
      });

      test('timestamp is recent', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final position = _makePosition();
        final reading = repo.buildReading(position, _testTarget);
        final after = DateTime.now().add(const Duration(seconds: 1));

        expect(reading.timestamp.isAfter(before), isTrue);
        expect(reading.timestamp.isBefore(after), isTrue);
      });
    });
  });
}
