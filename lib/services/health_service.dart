import 'package:health/health.dart';

class HealthService {
  final Health health = Health();

  Future<int> getTodaySteps() async {
    try {
      // For Android 15, we need to use Health Connect
      // Request permissions
      bool granted = await health.requestAuthorization(
        [HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ],
      );

      if (!granted) {
        print("Permission not granted");
        return 0;
      }

      // Get today's steps
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      int? steps = await health.getTotalStepsInInterval(startOfDay, now);

      print("Today's steps: $steps");
      return steps ?? 0;

    } catch (e) {
      print("Error: $e");
      return 0;
    }
  }
}