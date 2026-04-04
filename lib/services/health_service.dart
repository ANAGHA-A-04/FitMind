import 'package:health/health.dart';

class HealthService {
  final Health health = Health();

  Future<int> getTodaySteps() async {
    try {
      final types = [HealthDataType.STEPS];

      bool granted = await health.requestAuthorization(
        types,
        permissions: [HealthDataAccess.READ],
      );

      print("Authorization granted: $granted");

      if (!granted) {
        return 0;
      }

      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      int? steps = await health.getTotalStepsInInterval(startOfDay, now);

      print("Today's steps: $steps");

      return steps ?? 0;

    } catch (e) {
      print("Health Error: $e");
      return 0;
    }
  }
}