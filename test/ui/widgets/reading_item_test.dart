import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:detrack_app/data/models/location_reading.dart';
import 'package:detrack_app/ui/widgets/reading_item.dart';

Widget _buildWidget(LocationReading reading) {
  return MaterialApp(home: Scaffold(body: ReadingItem(reading: reading)));
}

void main() {
  group('ReadingItem', () {
    testWidgets('displays distance in meters when below 1000 m', (tester) async {
      final reading = LocationReading(
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        latitude: 14.5995,
        longitude: 120.9842,
        distance: 500.0,
      );
      await tester.pumpWidget(_buildWidget(reading));
      expect(find.text('500.0 m'), findsOneWidget);
    });

    testWidgets('displays distance in km when 1000 m or above', (tester) async {
      final reading = LocationReading(
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        latitude: 14.5995,
        longitude: 120.9842,
        distance: 1500.0,
      );
      await tester.pumpWidget(_buildWidget(reading));
      expect(find.text('1.50 km'), findsOneWidget);
    });

    testWidgets('displays timestamp as HH:MM:SS', (tester) async {
      final reading = LocationReading(
        timestamp: DateTime(2024, 1, 1, 9, 5, 3),
        latitude: 14.5995,
        longitude: 120.9842,
        distance: 100.0,
      );
      await tester.pumpWidget(_buildWidget(reading));
      expect(find.text('09:05:03'), findsOneWidget);
    });

    testWidgets('displays lat/lng with 6 decimal places', (tester) async {
      final reading = LocationReading(
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        latitude: 14.5995,
        longitude: 120.9842,
        distance: 100.0,
      );
      await tester.pumpWidget(_buildWidget(reading));
      expect(find.text('14.599500, 120.984200'), findsOneWidget);
    });

    testWidgets('displays exactly 1000 m as km', (tester) async {
      final reading = LocationReading(
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        latitude: 0.0,
        longitude: 0.0,
        distance: 1000.0,
      );
      await tester.pumpWidget(_buildWidget(reading));
      expect(find.text('1.00 km'), findsOneWidget);
    });
  });
}
