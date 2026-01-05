# terra_flutter

A Flutter plugin for Terra SDK - the Universal Health API.

## Features

- Initialize Terra SDK with developer credentials
- Connect to health data providers (Apple Health, FreestyleLibre)
- Fetch health data (activity, body, daily, sleep, nutrition, menstruation)
- Real-time health data updates via background delivery
- Manage planned workouts
- Glucose sensor activation and data reading

## Getting Started

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  terra_flutter_bridge: ^latest_version
```

### Basic Usage

```dart
import 'package:terra_flutter_bridge/terra_flutter_bridge.dart';
import 'package:terra_flutter_bridge/models/enums.dart';

// Initialize Terra
await TerraFlutter.initTerra('YOUR_DEV_ID', 'reference_id');

// Connect to a provider
await TerraFlutter.initConnection(
  Connection.appleHealth,
  'auth_token',
  true, // enable scheduler
  [], // custom permissions
);

// Get health data
final activityData = await TerraFlutter.getActivity(
  Connection.appleHealth,
  DateTime.now().subtract(Duration(days: 7)),
  DateTime.now(),
);
```

## Real-Time Health Data Updates

Terra SDK provides real-time updates for health data changes via HealthKit's background delivery. This allows your app to receive notifications when new health data is recorded, even when your app is in the background.

### Setup Health Update Stream

```dart
import 'package:terra_flutter_bridge/terra_flutter_bridge.dart';
import 'package:terra_flutter_bridge/models/health_update.dart';
import 'dart:async';

class HealthMonitorService {
  StreamSubscription<TerraHealthUpdate>? _subscription;
  
  void startMonitoring() {
    _subscription = TerraFlutter.healthUpdatesTyped.listen(
      (update) {
        print('Health Update: ${update.dataType}');
        print('Last Updated: ${update.lastUpdated}');
        print('Samples: ${update.samples.length}');
        
        for (var sample in update.samples) {
          print('  ${sample.value} at ${sample.timestamp}');
        }
      },
      onError: (error) {
        print('Error receiving health update: $error');
      },
    );
  }
  
  void stopMonitoring() {
    _subscription?.cancel();
  }
}
```

### Available Data Types

The health update stream can deliver the following data types:

- `STEPS` - Step count data
- `HEART_RATE` - Heart rate measurements
- `HEART_RATE_VARIABILITY` - HRV data
- `CALORIES` - Calorie burn data
- `DISTANCE` - Distance traveled

### Health Update Model

```dart
class TerraHealthUpdate {
  final String dataType;           // Type of health data
  final DateTime? lastUpdated;     // When data was last updated
  final List<TerraHealthSample> samples;  // Individual samples
}

class TerraHealthSample {
  final double value;       // Numeric value
  final DateTime timestamp; // When sample was recorded
}
```

### Using Raw Map Stream

If you prefer working with raw maps instead of typed objects:

```dart
TerraFlutter.healthUpdates.listen((map) {
  final dataType = map['dataType'] as String;
  final samples = map['samples'] as List;
  // Process raw data
});
```

### Background Delivery Setup

To enable background delivery on iOS, make sure to:

1. Enable HealthKit in your Xcode project capabilities

2. Add HealthKit usage description to `Info.plist`:

```xml
<key>NSHealthShareUsageDescription</key>
<string>We need access to your health data to track your fitness progress</string>
<key>NSHealthUpdateUsageDescription</key>
<string>We need to write workout data to your Health app</string>
```

3. Call `initConnection` with `schedulerOn: true` to enable background delivery

## Additional Resources

For help getting started with Flutter, view the

