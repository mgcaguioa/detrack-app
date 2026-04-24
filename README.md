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
https://raw.githubusercontent.com/mgcaguioa/detrack-target/main/target.json
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

## Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `geolocator` | GPS location access |
| `permission_handler` | Runtime permission requests |
| `http` | Fetching target JSON from GitHub |
