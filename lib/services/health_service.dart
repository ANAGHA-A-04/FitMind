import 'package:health/health.dart';

class HealthService {
  final Health health = Health();

  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    print("🚀 HealthService called");

    await health.configure();

    // 🔥 FORCE OPEN PERMISSION SCREEN
    bool requested = await health.requestAuthorization(
      [HealthDataType.STEPS],
      permissions: [HealthDataAccess.READ],
    );

    print("Permission result: $requested");

    if (!requested) {
      print("❌ Permission NOT granted");
      return 0;
    }

    try {
      int? steps = await health.getTotalStepsInInterval(midnight, now);

      print("✅ TODAY STEPS (API): $steps");

      return steps ?? 0;
    } catch (e) {
      print("❌ Error: $e");
      return 0;
    }
  }
}