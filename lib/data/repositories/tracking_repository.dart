import 'package:geolocator/geolocator.dart';

import '../../core/utils/haversine.dart';
import '../models/location_reading.dart';
import '../models/target.dart';
import '../sources/location_service.dart';
import '../sources/mock_api_service.dart';

class TrackingRepository {
  final LocationService _locationService;
  final MockApiService _apiService;

  TrackingRepository({
    required LocationService locationService,
    required MockApiService apiService,
  })  : _locationService = locationService,
        _apiService = apiService;

  Future<bool> requestPermission() => _locationService.requestPermission();

  Future<Target> getTarget() => _apiService.fetchTarget();

  Future<Position> getLocation() => _locationService.getCurrentLocation();

  /// Builds a [LocationReading] from the current position and a known target.
  LocationReading buildReading(Position position, Target target) {
    final distance = haversineDistance(
      position.latitude,
      position.longitude,
      target.targetLat,
      target.targetLng,
    );

    return LocationReading(
      timestamp: DateTime.now(),
      latitude: position.latitude,
      longitude: position.longitude,
      distance: distance,
    );
  }
}
