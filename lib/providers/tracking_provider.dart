import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../data/models/location_reading.dart';
import '../data/models/target.dart';
import '../data/repositories/tracking_repository.dart';

class TrackingProvider extends ChangeNotifier {
  final TrackingRepository _repository;

  TrackingProvider({required TrackingRepository repository})
      : _repository = repository;

  bool isTracking = false;
  Target? target;
  String? errorMessage;
  int filterCount = 5;

  final List<LocationReading> _readings = [];

  List<LocationReading> get readings => List.unmodifiable(_readings);

  /// Returns the most recent [filterCount] readings, newest first.
  List<LocationReading> get filteredReadings {
    final all = _readings.reversed.toList();
    return all.take(filterCount).toList();
  }

  Timer? _timer;

  Future<void> startTracking() async {
    // Guard against stacking timers on rapid taps.
    if (_timer != null) return;

    errorMessage = null;

    final granted = await _repository.requestPermission();
    if (!granted) {
      errorMessage = 'Location permission denied.';
      notifyListeners();
      return;
    }

    try {
      target = await _repository.getTarget();
    } catch (e) {
      errorMessage = 'Failed to fetch target: $e';
      notifyListeners();
      return;
    }

    isTracking = true;
    notifyListeners();

    // Collect immediately, then every 5 seconds.
    await _collectLocation();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _collectLocation();
    });
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    isTracking = false;
    notifyListeners();
  }

  Future<void> _collectLocation() async {
    try {
      final position = await _repository.getLocation();
      final reading = _repository.buildReading(position, target!);
      _readings.add(reading);
      notifyListeners();
    } on LocationServiceDisabledException {
      errorMessage = 'Location services are disabled.';
      stopTracking();
    } on PermissionDeniedException {
      errorMessage = 'Location permission denied.';
      stopTracking();
    } catch (e) {
      errorMessage = 'Location error: $e';
      notifyListeners();
    }
  }

  void setFilter(int count) {
    filterCount = count;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
