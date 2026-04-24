import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:detrack_app/data/sources/mock_api_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;
  late MockApiService service;

  setUp(() {
    mockClient = MockHttpClient();
    service = MockApiService(client: mockClient);
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('MockApiService.fetchTarget', () {
    test('returns parsed Target on 200 response', () async {
      final body = jsonEncode({
        'id': 'remote-target',
        'targetLat': 10.3157,
        'targetLng': 123.8854,
      });
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(body, 200));

      final target = await service.fetchTarget();

      expect(target.id, 'remote-target');
      expect(target.targetLat, 10.3157);
      expect(target.targetLng, 123.8854);
    });

    test('returns fallback Target on non-200 response', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      final target = await service.fetchTarget();

      expect(target.id, 'default');
      expect(target.targetLat, 14.5995);
      expect(target.targetLng, 120.9842);
    });

    test('returns fallback Target when client throws', () async {
      when(() => mockClient.get(any())).thenThrow(Exception('network error'));

      final target = await service.fetchTarget();

      expect(target.id, 'default');
    });

    test('returns fallback Target on invalid JSON body', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response('not json', 200));

      final target = await service.fetchTarget();

      expect(target.id, 'default');
    });
  });
}
