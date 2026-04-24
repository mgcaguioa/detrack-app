import 'package:flutter/material.dart';

import '../../data/models/location_reading.dart';

class ReadingItem extends StatelessWidget {
  final LocationReading reading;

  const ReadingItem({super.key, required this.reading});

  String get _formattedTime {
    final t = reading.timestamp;
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get _formattedDistance {
    if (reading.distance >= 1000) {
      return '${(reading.distance / 1000).toStringAsFixed(2)} km';
    }
    return '${reading.distance.toStringAsFixed(1)} m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formattedTime,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reading.latitude.toStringAsFixed(6)}, '
                    '${reading.longitude.toStringAsFixed(6)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text(
              _formattedDistance,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
