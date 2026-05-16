import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FoodService {
  static const String baseUrl = "http://10.184.213.220:5003/api";

  static Future<Map<String, dynamic>> analyzeFood(String imagePath) async {
    final uri = Uri.parse("$baseUrl/food/analyze");

    var request = http.MultipartRequest("POST", uri);

    request.files.add(
      await http.MultipartFile.fromPath("image", imagePath),
    );

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception("Failed to analyze image food");
    }
  }

  static Future<Map<String, dynamic>> analyzeManualFood(String foodName) async {
    final uri = Uri.parse("$baseUrl/food/manual");

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "food": foodName,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to analyze manual food");
    }
  }

  static int calculateDietScore(Map<String, dynamic> resultData, double quantity) {
    final factor = quantity / 100;

    final calories = ((resultData["calories"] ?? 0) * factor).toDouble();
    final protein = ((resultData["protein"] ?? 0) * factor).toDouble();
    final fiber = ((resultData["fiber"] ?? 0) * factor).toDouble();
    final fat = ((resultData["fat"] ?? 0) * factor).toDouble();

    int score = 50;

    if (calories <= 300) score += 20;
    else if (calories <= 500) score += 10;
    else if (calories <= 700) score += 5;
    else score -= 10;

    if (protein >= 10) score += 10;
    else if (protein >= 5) score += 5;

    if (fiber >= 5) score += 10;
    else if (fiber >= 2) score += 5;

    if (fat <= 15) score += 10;
    else if (fat <= 25) score += 5;
    else score -= 5;

    return score.clamp(0, 100);
  }

  static Future<void> saveDietScoreLocally({
    required int levelId,
    required int dietScore,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("diet_score_$levelId", dietScore);
    await prefs.setBool("diet_done_$levelId", true);
  }

  static Future<int?> getDietScoreForLevel(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("diet_score_$levelId");
  }

  static Future<bool> isDietDone(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("diet_done_$levelId") ?? false;
  }

  static Future<bool> saveDietScoreToBackend({
    required int userId,
    required int levelId,
    required int dietScore,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/save_diet_score"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "userId": userId,
          "levelId": levelId,
          "dietScore": dietScore,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}