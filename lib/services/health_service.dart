import 'dart:io';

import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  final Health health = Health();

  Future<int> getTodaySteps() async {
    try {
      final types = [HealthDataType.STEPS];

      if (Platform.isAndroid) {
        final activityPermission = await Permission.activityRecognition.request();
        if (!activityPermission.isGranted) {
          print('Activity recognition permission denied: $activityPermission');
          return 0;
        }
      }

      bool granted = await health.requestAuthorization(
        types,
        permissions: [HealthDataAccess.READ],
      );

      print('Health authorization granted: $granted');
      if (!granted) {
        return 0;
      }

      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);

      int? steps = await health.getTotalStepsInInterval(startOfDay, now);
      print('Start: $startOfDay');
      print('Now: $now');
      print("getTotalStepsInInterval result: $steps");

      if (steps == null || steps == 0) {
        final data = await health.getHealthDataFromTypes(
          types: types,
          startTime: startOfDay,
          endTime: now,
        );
        print('getHealthDataFromTypes count: ${data.length}');
        if (data.isEmpty) {
          print('No raw step points were returned by Health API.');
          return 0;
        }

        for (var i = 0; i < data.length && i < 10; i++) {
          final dp = data[i];
          print('step point #${i + 1}: type=${dp.type.name}, value=${dp.value}, unit=${dp.unit.name}, from=${dp.dateFrom}, to=${dp.dateTo}');
        }

        final fallbackSteps = data.fold<int>(0, (sum, dp) {
          if (dp.value is NumericHealthValue) {
            return sum + (dp.value as NumericHealthValue).numericValue.toInt();
          }
          return sum;
        });
        print('Fallback summed steps: $fallbackSteps');
        return fallbackSteps;
      }

      return steps;

    } catch (e) {
      print('Health Error: $e');
      return 0;
    }
  }
}