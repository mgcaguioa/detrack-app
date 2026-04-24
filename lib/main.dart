import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/tracking_repository.dart';
import 'data/sources/location_service.dart';
import 'data/sources/mock_api_service.dart';
import 'providers/tracking_provider.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(const DetrackApp());
}

class DetrackApp extends StatelessWidget {
  const DetrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackingProvider(
        repository: TrackingRepository(
          locationService: LocationService(),
          apiService: MockApiService(),
        ),
      ),
      child: MaterialApp(
        title: 'Detrack',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
