/// Represents a real-time health data update from Terra SDK's background delivery.
class TerraHealthUpdate {
  /// The type of health data (e.g., "STEPS", "HEART_RATE", "CALORIES", "DISTANCE", "HEART_RATE_VARIABILITY")
  final String dataType;

  /// When the data was last updated
  final DateTime? lastUpdated;

  /// Individual health data samples
  final List<TerraHealthSample> samples;

  TerraHealthUpdate({
    required this.dataType,
    this.lastUpdated,
    required this.samples,
  });

  factory TerraHealthUpdate.fromMap(Map<String, dynamic> map) {
    final samplesData = map['samples'] as List? ?? [];
    final samples = samplesData
        .map((s) =>
            TerraHealthSample.fromMap(Map<String, dynamic>.from(s as Map)))
        .toList();

    final lastUpdatedTimestamp = map['lastUpdated'] as num?;
    final lastUpdated = lastUpdatedTimestamp != null && lastUpdatedTimestamp > 0
        ? DateTime.fromMillisecondsSinceEpoch(
            (lastUpdatedTimestamp * 1000).toInt())
        : null;

    return TerraHealthUpdate(
      dataType: map['dataType'] as String,
      lastUpdated: lastUpdated,
      samples: samples,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dataType': dataType,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
      'samples': samples.map((s) => s.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'TerraHealthUpdate(dataType: $dataType, lastUpdated: $lastUpdated, samples: ${samples.length})';
  }
}

/// Individual health data sample with value and timestamp
class TerraHealthSample {
  /// The numeric value of the health data
  final double value;

  /// When this sample was recorded
  final DateTime timestamp;

  TerraHealthSample({
    required this.value,
    required this.timestamp,
  });

  factory TerraHealthSample.fromMap(Map<String, dynamic> map) {
    final timestampValue = map['timestamp'] as num;
    return TerraHealthSample(
      value: (map['value'] as num).toDouble(),
      timestamp:
          DateTime.fromMillisecondsSinceEpoch((timestampValue * 1000).toInt()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'TerraHealthSample(value: $value, timestamp: $timestamp)';
  }
}
