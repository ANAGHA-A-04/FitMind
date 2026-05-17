import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LevelService {
  static const String baseUrl = "http://10.184.213.12:5002";

  Future<void> addXP(int xp) async {
    final prefs = await SharedPreferences.getInstance();

    int currentXP = prefs.getInt("xp") ?? 0;
    int level = prefs.getInt("level") ?? 1;

    currentXP += xp;

    if (currentXP >= 100 && level == 0) {
      level = 1; // level 0 completed
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

  static Future<void> setActiveLevel(int nextLevel) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt("activeLevel") ?? 0;
    if (nextLevel > current) {
      await prefs.setInt("activeLevel", nextLevel);
    }
  }
   static int wellnessScoreFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'stressed overworker':
        return 35;
      case 'sedentary/relaxed':
        return 70;
      case 'high-energy achiever':
        return 90;
      default:
        return 50;
    }
  }

  static Future<bool> saveWellnessScoreToBackend({
    required int userId,
    required int levelId,
    required int wellnessScore,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/save_wellness_score"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "levelId": levelId,
          "wellnessScore": wellnessScore,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<void> saveWellnessScoreLocally({
    required int levelId,
    required int wellnessScore,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("wellness_score_$levelId", wellnessScore);
    await prefs.setBool("wellness_done_$levelId", true);
  }

  static Future<int?> getWellnessScoreForLevel(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("wellness_score_$levelId");
  }

  static Future<bool> isWellnessDone(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("wellness_done_$levelId") ?? false;
  }
}