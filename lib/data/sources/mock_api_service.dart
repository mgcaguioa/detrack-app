import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/target.dart';

class MockApiService {
  final http.Client _client;

  MockApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _targetUrl =
      'https://raw.githubusercontent.com/mgcaguioa/mock-data/main/detrack-target.json';

  // Fallback used when the remote fetch fails.
  static const _fallbackTarget = Target(
    id: 'default',
    targetLat: 14.5995,
    targetLng: 120.9842,
  );

  /// Fetches the target from the remote JSON endpoint.
  /// Returns the fallback target on any error.
  Future<Target> fetchTarget() async {
    try {
      final response = await _client
          .get(Uri.parse(_targetUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Target.fromJson(json);
      }
    } catch (_) {
      // Network error, timeout, or parse failure — use fallback.
    }

    return _fallbackTarget;
  }
}
