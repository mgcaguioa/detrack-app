# Detrack App

A Flutter location tracking app that periodically records your GPS position and computes the distance to a configurable target coordinate using the Haversine formula.

---

## Setup

### Prerequisites

- Flutter SDK (latest stable)
- Xcode (for iOS) or Android Studio (for Android)
- A physical device or simulator with location services

### Install

```bash
flutter pub get
flutter run
```

---

## Required Permissions

### iOS

The following keys are already configured in `ios/Runner/Info.plist`:

| Key | Purpose |
|-----|---------|
| `NSLocationWhenInUseUsageDescription` | Access location while app is open |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | Access location in background |

### Android

The following permissions are declared in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

The app requests runtime permission on first launch via `permission_handler`.

---

## Configuring the Target (Mock API)

The app fetches the target coordinate from a static JSON file hosted on GitHub:

```
https://raw.githubusercontent.com/mgcaguioa/mock-data/main/detrack-target.json
```

### JSON format

```json
{
  "id": "target-1",
  "targetLat": 14.5995,
  "targetLng": 120.9842
}
```

### To use your own target

1. Create a public GitHub repository named `mock-data`
2. Add a `detrack-target.json` file with the structure above
3. The app will pick it up automatically on next launch

If the fetch fails (no internet, missing file, wrong format), the app silently falls back to a default target at `(14.5995, 120.9842)` — Manila, Philippines.

---

## Architecture

The project follows a **clean architecture-lite** approach — UI is decoupled from business logic, and external dependencies are isolated behind service classes.

```
lib/
 ├── core/
 │    └── utils/
 │         └── haversine.dart        # Pure Haversine distance function
 │
 ├── data/
 │    ├── models/
 │    │    ├── target.dart            # Target coordinate model
 │    │    └── location_reading.dart  # Single GPS reading + distance
 │    ├── sources/
 │    │    ├── location_service.dart  # GPS + permission handling
 │    │    └── mock_api_service.dart  # HTTP fetch of target JSON
 │    └── repositories/
 │         └── tracking_repository.dart  # Orchestrates services + Haversine
 │
 ├── providers/
 │    └── tracking_provider.dart     # State + timer + business logic
 │
 ├── ui/
 │    ├── screens/
 │    │    └── home_screen.dart       # Main screen
 │    └── widgets/
 │         └── reading_item.dart      # Single reading card
 │
 └── main.dart                        # App entry point + DI wiring
```

### Key decisions

- **TrackingProvider** owns the 5-second `Timer.periodic` and guards against stacked timers on rapid taps
- **TrackingRepository** is the only layer that calls `haversineDistance()` — business logic stays out of the UI and provider
- **MockApiService** always returns a usable target — network failure is handled gracefully with a fallback
- All state mutations go through the provider; widgets only call provider methods

---

## Running Tests

All tests live under the `test/` directory and mirror the `lib/` folder structure.

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/core/utils/haversine_test.dart
```

### Test Coverage

| Test file                                              | What it covers                                      |
|--------------------------------------------------------|-----------------------------------------------------|
| `test/core/utils/haversine_test.dart`                  | Haversine formula accuracy and edge cases           |
| `test/data/models/target_test.dart`                    | Target model JSON parsing                           |
| `test/data/models/location_reading_test.dart`          | LocationReading model construction                  |
| `test/data/sources/mock_api_service_test.dart`         | HTTP fetch and fallback behaviour                   |
| `test/data/repositories/tracking_repository_test.dart` | Repository orchestration and distance computation   |
| `test/providers/tracking_provider_test.dart`           | Start/stop tracking, timer management, filter logic |
| `test/ui/screens/home_screen_test.dart`                | Home screen rendering and user interactions         |
| `test/ui/widgets/reading_item_test.dart`               | Reading card display                                |

No external test dependencies are required — the suite uses only the packages already listed below plus Flutter's built-in `flutter_test`.

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `geolocator` | GPS location access |
| `permission_handler` | Runtime permission requests |
| `http` | Fetching target JSON from GitHub |
