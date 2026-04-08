import 'package:shared_preferences/shared_preferences.dart';

class LevelService {

  Future<void> addXP(int xp) async {
    final prefs = await SharedPreferences.getInstance();

    int currentXP = prefs.getInt("xp") ?? 0;
    int level = prefs.getInt("level") ?? 1;

    currentXP += xp;

    if (currentXP >= 100 && level == 1) {
      level = 2; // level 1 completed
    }

    await prefs.setInt("xp", currentXP);
    await prefs.setInt("level", level);
  }

  Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("xp") ?? 0;
  }

  Future<int> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("level") ?? 1;
  }

  // Phase 1: Daily Checkin Lock
  static Future<bool> hasCheckedInToday() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastCheckIn = prefs.getString('lastCheckInDate');
    final String today = DateTime.now().toIso8601String().split('T')[0];
    return lastCheckIn == today;
  }

  static Future<void> markCheckedInToday() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('lastCheckInDate', today);
  }

  // Phase 2: Active Level Managing (Unlocking logic)
  static Future<int> getActiveLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("activeLevel") ?? 0; // Starts at Level 0
  }

  static Future<void> unlockNextLevel() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt("activeLevel") ?? 0;
    await prefs.setInt("activeLevel", current + 1);
  }
}