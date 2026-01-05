import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:terra_flutter_bridge/models/enums.dart';
import 'package:terra_flutter_bridge/models/responses.dart';
import 'package:terra_flutter_bridge/models/planned_workout.dart';
import 'package:terra_flutter_bridge/models/health_update.dart';

String convertToProperIsoFormat(DateTime date) {
  return date.toUtc().toIso8601String();
}

// Functions bridging
class TerraFlutter {
  static const MethodChannel _channel = MethodChannel('terra_flutter_bridge');
  static const EventChannel _healthUpdatesChannel =
      EventChannel('terra_flutter_bridge/health_updates');

  static Stream<Map<String, dynamic>>? _healthUpdatesStream;

  /// Stream of real-time health data updates from HealthKit background delivery.
  ///
  /// This stream receives updates from Terra's background health data processing.
  /// Each update contains:
  /// - `dataType`: The type of health data (e.g., "STEPS", "HEART_RATE", "CALORIES")
  /// - `lastUpdated`: Unix timestamp of when the data was last updated
  /// - `samples`: List of data samples, each with `value` and `timestamp`
  ///
  /// Example usage:
  /// ```dart
  /// TerraFlutter.healthUpdates.listen((update) {
  ///   print('Data type: ${update['dataType']}');
  ///   final samples = update['samples'] as List;
  ///   print('Received ${samples.length} samples');
  /// });
  /// ```
  static Stream<Map<String, dynamic>> get healthUpdates {
    _healthUpdatesStream ??= _healthUpdatesChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _healthUpdatesStream!;
  }

  /// Typed stream of health updates. Use this for easier access to typed data.
  ///
  /// Example usage:
  /// ```dart
  /// TerraFlutter.healthUpdatesTyped.listen((update) {
  ///   print('${update.dataType}: ${update.samples.length} samples');
  ///   for (var sample in update.samples) {
  ///     print('  ${sample.value} at ${sample.timestamp}');
  ///   }
  /// });
  /// ```
  static Stream<TerraHealthUpdate> get healthUpdatesTyped {
    return healthUpdates.map((map) => TerraHealthUpdate.fromMap(map));
  }

  static Future<String?> testFunction(String text) async {
    final String? version =
        await _channel.invokeMethod('testFunction', {"text": text});
    return version;
  }

  static Future<SuccessMessage?> initTerra(
      String devID, String referenceID) async {
    return SuccessMessage.fromJson(
        Map<String, dynamic>.from(await _channel.invokeMethod('initTerra', {
      "devID": devID,
      "referenceID": referenceID,
    })));
  }

  static Future<SuccessMessage?> initConnection(
      Connection connection,
      String token,
      bool schedulerOn,
      List<CustomPermission> customPermissions) async {
    return SuccessMessage.fromJson(Map<String, dynamic>.from(
        await _channel.invokeMethod('initConnection', {
      "connection": connection.connectionString,
      "token": token,
      "schedulerOn": schedulerOn,
      "customPermissions":
          customPermissions.map((c) => c.customPermissionString).toList()
    })));
  }

  static Future<UserId?> getUserId(Connection connection) async {
    return UserId.fromJson(Map<String, dynamic>.from(await _channel
        .invokeMethod(
            'getUserId', {"connection": connection.connectionString})));
  }

  static Future<bool> isHealthConnectAvailable() async {
    return await _channel.invokeMethod("isHealthConnectAvailable");
  }

  static Future<DataMessage?> getActivity(
      Connection connection, DateTime startDate, DateTime endDate,
      {bool toWebhook = true}) async {
    return DataMessage.fromJson(
        Map<String, dynamic>.from(await _channel.invokeMethod('getActivity', {
      "connection": connection.connectionString,
      "startDate": convertToProperIsoFormat(startDate),
      "endDate": convertToProperIsoFormat(endDate),
      "toWebhook": toWebhook
    })));
  }

  static Future<DataMessage?> getAthlete(Connection connection,
      {bool toWebhook = true}) async {
    return DataMessage.fromJson(Map<String, dynamic>.from(await _channel
        .invokeMethod('getAthlete', {
      "connection": connection.connectionString,
      "toWebhook": toWebhook
    })));
  }

  static Future<DataMessage?> getBody(
      Connection connection, DateTime startDate, DateTime endDate,
      {bool toWebhook = true}) async {
    return DataMessage.fromJson(
        Map<String, dynamic>.from(await _channel.invokeMethod('getBody', {
      "connection": connection.connectionString,
      "startDate": convertToProperIsoFormat(startDate),
      "endDate": convertToProperIsoFormat(endDate),
      "toWebhook": toWebhook
    })));
  }

  static Future<DataMessage?> getDaily(
      Connection connection, DateTime startDate, DateTime endDate,
      {bool toWebhook = true}) async {
    return DataMessage.fromJson(
        Map<String, dynamic>.from(await _channel.invokeMethod('getDaily', {
      "connection": connection.connectionString,
      "startDate": convertToProperIsoFormat(startDate),
      "endDate": convertToProperIsoFormat(endDate),
      "toWebhook": toWebhook
    })));
  }

  static Future<DataMessage?> getMenstruation(
      Connection connection, DateTime startDate, DateTime endDate,
      {bool toWebhook = true}) async {
    return DataMessage.fromJson(Map<String, dynamic>.from(
        await _channel.invokeMethod('getMenstruation', {
      "connection": connection.connectionString,
      "startDate": convertToProperIsoFormat(startDate),
      "endDate": convertToProperIsoFormat(endDate),
      "toWebhook": toWebhook
    })));
  }

  static Future<DataMessage?> getNutrition(
      Connection connection, DateTime startDate, DateTime endDate,
      {bool toWebhook = true}) async {
    return DataMessage.fromJson(
        Map<String, dynamic>.from(await _channel.invokeMethod('getNutrition', {
      "connection": connection.connectionString,
      "startDate": convertToProperIsoFormat(startDate),
      "endDate": convertToProperIsoFormat(endDate),
      "toWebhook": toWebhook
    })));
  }

  static Future<DataMessage?> getSleep(
      Connection connection, DateTime startDate, DateTime endDate,
      {bool toWebhook = true}) async {
    return DataMessage.fromJson(
        Map<String, dynamic>.from(await _channel.invokeMethod('getSleep', {
      "connection": connection.connectionString,
      "startDate": convertToProperIsoFormat(startDate),
      "endDate": convertToProperIsoFormat(endDate),
      "toWebhook": toWebhook
    })));
  }

  static Future<String?> activateGlucoseSensor() async {
    final String? success =
        await _channel.invokeMethod('activateGlucoseSensor');
    return success;
  }

  // only for apple
  static Future<String?> readGlucoseData() async {
    final String? success = await _channel.invokeMethod('readGlucoseData');
    return success;
  }

  static Future<ListDataMessage?> getPlannedWorkouts(
      Connection connection) async {
    return ListDataMessage.fromJson(Map<String, dynamic>.from(await _channel
        .invokeMethod('getPlannedWorkouts',
            {"connection": connection.connectionString})));
  }

  static Future<SuccessMessage?> deletePlannedWorkout(
      Connection connection, String id) async {
    return SuccessMessage.fromJson(Map<String, dynamic>.from(await _channel
        .invokeMethod('deletePlannedWorkout',
            {"connection": connection.connectionString, "workoutId": id})));
  }

  static Future<SuccessMessage?> completePlannedWorkout(
      Connection connection, String id, DateTime? at) async {
    return SuccessMessage.fromJson(Map<String, dynamic>.from(
        await _channel.invokeMethod('completePlannedWorkout', {
      "connection": connection.connectionString,
      "workoutId": id,
      "at": convertToProperIsoFormat(at ?? DateTime.now())
    })));
  }

  static Future<SuccessMessage?> postPlannedWorkout(
      Connection connection, TerraPlannedWorkout payload) async {
    return SuccessMessage.fromJson(Map<String, dynamic>.from(
        await _channel.invokeMethod('postPlannedWorkout', {
      "connection": connection.connectionString,
      "payload": jsonEncode(payload.toJson())
    })));
  }

  static Future<Set<String>> getGivenPermissions() async {
    return Set<String>.from(await _channel.invokeMethod('getGivenPermissions'));
  }
}
