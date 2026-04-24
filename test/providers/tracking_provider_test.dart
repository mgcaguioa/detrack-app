import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

import 'package:detrack_app/data/models/location_reading.dart';
import 'package:detrack_app/data/models/target.dart';
import 'package:detrack_app/data/repositories/tracking_repository.dart';
import 'package:detrack_app/providers/tracking_provider.dart';

class MockTrackingRepository extends Mock implements TrackingRepository {}

const _testTarget = Target(id: 'test', targetLat: 14.5995, targetLng: 120.9842);

void _registerFallbacks() {
  registerFallbackValue(Position(
    latitude: 0,
    longitude: 0,
    timestamp: DateTime(2024),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  ));
  registerFallbackValue(_testTarget);
}

Position _makePosition() => Position(
      latitude: 14.6000,
      longitude: 120.9900,
      timestamp: DateTime(2024),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

LocationReading _makeReading({int second = 0}) => LocationReading(
      timestamp: DateTime(2024, 1, 1, 0, 0, second),
      latitude: 14.6,
      longitude: 120.99,
      distance: 100.0,
    );

void _stubSuccess(MockTrackingRepository repo, {LocationReading? reading}) {
  when(() => repo.requestPermission()).thenAnswer((_) async => true);
  when(() => repo.getTarget()).thenAnswer((_) async => _testTarget);
  when(() => repo.getLocation()).thenAnswer((_) async => _makePosition());
  when(() => repo.buildReading(any(), any())).thenReturn(reading ?? _makeReading());
}

void main() {
  setUpAll(_registerFallbacks);

  late MockTrackingRepository mockRepo;
  late TrackingProvider provider;

  setUp(() {
    mockRepo = MockTrackingRepository();
    provider = TrackingProvider(repository: mockRepo);
    addTearDown(provider.dispose);
  });

  group('TrackingProvider — initial state', () {
    test('isTracking is false', () => expect(provider.isTracking, isFalse));
    test('readings is empty', () => expect(provider.readings, isEmpty));
    test('filterCount is 5', () => expect(provider.filterCount, 5));
    test('errorMessage is null', () => expect(provider.errorMessage, isNull));
  });

  group('startTracking', () {
    test('sets isTracking to true on success', () async {
      _stubSuccess(mockRepo);
      await provider.startTracking();
      expect(provider.isTracking, isTrue);
    });

    test('adds one reading immediately on success', () async {
      _stubSuccess(mockRepo);
      await provider.startTracking();
      expect(provider.readings.length, 1);
    });

    test('clears errorMessage on success', () async {
      _stubSuccess(mockRepo);
      provider.errorMessage = 'old error';
      await provider.startTracking();
      expect(provider.errorMessage, isNull);
    });

    test('sets errorMessage and stays stopped when permission denied', () async {
      when(() => mockRepo.requestPermission()).thenAnswer((_) async => false);

      await provider.startTracking();

      expect(provider.isTracking, isFalse);
      expect(provider.errorMessage, 'Location permission denied.');
    });

    test('guards against double timers — second call is a no-op', () async {
      _stubSuccess(mockRepo);
      await provider.startTracking();
      await provider.startTracking(); // should return early

      // requestPermission was only called once (from the first startTracking)
      verify(() => mockRepo.requestPermission()).called(1);
    });
  });

  group('_collectLocation error handling', () {
    test('LocationServiceDisabledException stops tracking and sets error', () async {
      when(() => mockRepo.requestPermission()).thenAnswer((_) async => true);
      when(() => mockRepo.getTarget()).thenAnswer((_) async => _testTarget);
      when(() => mockRepo.getLocation())
          .thenThrow(const LocationServiceDisabledException());

      await provider.startTracking();

      expect(provider.isTracking, isFalse);
      expect(provider.errorMessage, 'Location services are disabled.');
    });

    test('PermissionDeniedException stops tracking and sets error', () async {
      when(() => mockRepo.requestPermission()).thenAnswer((_) async => true);
      when(() => mockRepo.getTarget()).thenAnswer((_) async => _testTarget);
      when(() => mockRepo.getLocation())
          .thenThrow(PermissionDeniedException('denied'));

      await provider.startTracking();

      expect(provider.isTracking, isFalse);
      expect(provider.errorMessage, 'Location permission denied.');
    });

    test('generic exception sets errorMessage without stopping tracking', () async {
      when(() => mockRepo.requestPermission()).thenAnswer((_) async => true);
      when(() => mockRepo.getTarget()).thenAnswer((_) async => _testTarget);
      when(() => mockRepo.getLocation())
          .thenThrow(Exception('unexpected'));

      await provider.startTracking();

      // isTracking was set to true before _collectLocation; generic error doesn't stop it
      expect(provider.errorMessage, contains('Location error:'));
    });
  });

  group('stopTracking', () {
    test('sets isTracking to false', () async {
      _stubSuccess(mockRepo);
      await provider.startTracking();
      provider.stopTracking();
      expect(provider.isTracking, isFalse);
    });

    test('preserves existing readings', () async {
      _stubSuccess(mockRepo);
      await provider.startTracking();
      provider.stopTracking();
      expect(provider.readings, isNotEmpty);
    });

    test('can be called when not tracking without error', () {
      expect(() => provider.stopTracking(), returnsNormally);
    });
  });

  group('setFilter', () {
    test('updates filterCount', () {
      provider.setFilter(10);
      expect(provider.filterCount, 10);
    });

    test('notifies listeners', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.setFilter(15);
      expect(notified, isTrue);
    });
  });

  group('filteredReadings', () {
    Future<void> addReadings(int count) async {
      for (int i = 0; i < count; i++) {
        _stubSuccess(mockRepo, reading: _makeReading(second: i));
        await provider.startTracking();
        provider.stopTracking();
      }
    }

    test('returns all readings when count is below filterCount', () async {
      await addReadings(3);
      provider.setFilter(5);
      expect(provider.filteredReadings.length, 3);
    });

    test('returns at most filterCount readings', () async {
      await addReadings(7);
      provider.setFilter(5);
      expect(provider.filteredReadings.length, 5);
    });

    test('returns newest readings first', () async {
      await addReadings(3);
      // Readings were added with second = 0, 1, 2
      // filteredReadings reverses the list, so first item has second = 2
      final filtered = provider.filteredReadings;
      expect(filtered.first.timestamp.second, 2);
      expect(filtered.last.timestamp.second, 0);
    });

    test('returns empty list when no readings', () {
      expect(provider.filteredReadings, isEmpty);
    });
  });

  group('dispose', () {
    test('can dispose while tracking without throwing', () async {
      // Use a fresh provider so tearDown's dispose() isn't called a second time.
      final localMock = MockTrackingRepository();
      _stubSuccess(localMock);
      final localProvider = TrackingProvider(repository: localMock);
      await localProvider.startTracking();
      expect(() => localProvider.dispose(), returnsNormally);
    });
  });
}
