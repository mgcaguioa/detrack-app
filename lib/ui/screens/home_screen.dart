import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tracking_provider.dart';
import '../widgets/reading_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _filterOptions = [5, 10, 15, 20];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detrack App'),
        centerTitle: true,
      ),
      body: Consumer<TrackingProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              if (provider.errorMessage != null) _ErrorBanner(provider.errorMessage!),
              _Controls(provider: provider),
              const Divider(height: 1),
              Expanded(
                child: provider.filteredReadings.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: provider.filteredReadings.length,
                        itemBuilder: (_, index) => ReadingItem(
                          reading: provider.filteredReadings[index],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final TrackingProvider provider;

  const _Controls({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: provider.isTracking
                  ? provider.stopTracking
                  : provider.startTracking,
              icon: Icon(provider.isTracking ? Icons.stop : Icons.play_arrow),
              label: Text(provider.isTracking ? 'Stop' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.isTracking
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _FilterDropdown(provider: provider),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final TrackingProvider provider;

  const _FilterDropdown({required this.provider});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: provider.filterCount,
        items: HomeScreen._filterOptions
            .map((n) => DropdownMenuItem(
                  value: n,
                  child: Text('Last $n'),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) provider.setFilter(value);
        },
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'No readings yet.\nTap Start to begin tracking.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
