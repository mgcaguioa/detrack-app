import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import 'package:detrack_app/data/models/location_reading.dart';
import 'package:detrack_app/data/models/target.dart';
import 'package:detrack_app/data/repositories/tracking_repository.dart';
import 'package:detrack_app/providers/tracking_provider.dart';
import 'package:detrack_app/ui/screens/home_screen.dart';
import 'package:detrack_app/ui/widgets/reading_item.dart';

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
      latitude: 14.6,
      longitude: 120.99,
      timestamp: DateTime(2024),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

LocationReading _makeReading() => LocationReading(
      timestamp: DateTime(2024, 1, 1, 12, 0, 0),
      latitude: 14.6,
      longitude: 120.99,
      distance: 500.0,
    );

void main() {
  late MockTrackingRepository mockRepo;
  late TrackingProvider provider;

  setUpAll(_registerFallbacks);

  setUp(() {
    mockRepo = MockTrackingRepository();
    provider = TrackingProvider(repository: mockRepo);
  });

  Widget buildApp() {
    return ChangeNotifierProvider<TrackingProvider>.value(
      value: provider,
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  tearDown(() {
    provider.dispose();
  });

  group('HomeScreen', () {
    testWidgets('renders AppBar with Detrack App title', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Detrack App'), findsOneWidget);
    });

    testWidgets('shows Start button when not tracking', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Stop'), findsNothing);
    });

    testWidgets('shows empty state when no readings', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.byIcon(Icons.location_off), findsOneWidget);
      expect(find.text('No readings yet.\nTap Start to begin tracking.'),
          findsOneWidget);
    });

    testWidgets('shows Stop button after tracking starts', (tester) async {
      when(() => mockRepo.requestPermission()).thenAnswer((_) async => true);
      when(() => mockRepo.getTarget()).thenAnswer((_) async => _testTarget);
      when(() => mockRepo.getLocation()).thenAnswer((_) async => _makePosition());
      when(() => mockRepo.buildReading(any(), any())).thenReturn(_makeReading());

      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('Start'), findsNothing);

      provider.stopTracking();
      await tester.pump();
    });

    testWidgets('shows ReadingItem after successful tracking', (tester) async {
      when(() => mockRepo.requestPermission()).thenAnswer((_) async => true);
      when(() => mockRepo.getTarget()).thenAnswer((_) async => _testTarget);
      when(() => mockRepo.getLocation()).thenAnswer((_) async => _makePosition());
      when(() => mockRepo.buildReading(any(), any())).thenReturn(_makeReading());

      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.byType(ReadingItem), findsOneWidget);

      provider.stopTracking();
      await tester.pump();
    });

    testWidgets('shows error banner when permission is denied', (tester) async {
      when(() => mockRepo.requestPermission()).thenAnswer((_) async => false);

      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.text('Location permission denied.'), findsOneWidget);
    });

    testWidgets('shows current filter value in dropdown', (tester) async {
      await tester.pumpWidget(buildApp());
      // Default filterCount is 5, so 'Last 5' should be visible as selected value
      expect(find.text('Last 5'), findsOneWidget);
    });

    testWidgets('filter dropdown contains all options when opened',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Last 5'));
      await tester.pumpAndSettle();

      expect(find.text('Last 10'), findsOneWidget);
      expect(find.text('Last 15'), findsOneWidget);
      expect(find.text('Last 20'), findsOneWidget);
    });

    testWidgets('tapping Stop transitions back to Start button', (tester) async {
      when(() => mockRepo.requestPermission()).thenAnswer((_) async => true);
      when(() => mockRepo.getTarget()).thenAnswer((_) async => _testTarget);
      when(() => mockRepo.getLocation()).thenAnswer((_) async => _makePosition());
      when(() => mockRepo.buildReading(any(), any())).thenReturn(_makeReading());

      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Stop'));
      await tester.pump();

      expect(find.text('Start'), findsOneWidget);
      expect(provider.isTracking, isFalse);
    });

    testWidgets('changing filter updates displayed readings count',
        (tester) async {
      when(() => mockRepo.requestPermission()).thenAnswer((_) async => true);
      when(() => mockRepo.getTarget()).thenAnswer((_) async => _testTarget);
      when(() => mockRepo.getLocation()).thenAnswer((_) async => _makePosition());
      when(() => mockRepo.buildReading(any(), any())).thenReturn(_makeReading());

      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('Last 5'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last 10'));
      await tester.pumpAndSettle();

      expect(provider.filterCount, 10);
    });
  });
}
