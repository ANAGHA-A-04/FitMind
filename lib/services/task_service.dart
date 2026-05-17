import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskService {
  static const String baseUrl = "http://192.168.43.12:5000/api";

  static Future<Map<String, dynamic>> completeLevel({
    required String userId,
    required int level,
    required List<Map<String, dynamic>> tasks,
    required int wellnessScore,
    required int dietScore,
  }) async {
    try {
      // Prepare task completion data
      final taskData = tasks.map((task) {
        return {
          'name': task['name'],
          'isQuantifiable': task['isQuantifiable'] ?? false,
          'isCompleted': task['isCompleted'] ?? false,
          'targetValue': task['targetValue'],
          'actualValue': task['actualValue'] ?? 0,
        };
      }).toList();

      final response = await http.post(
        Uri.parse("$baseUrl/tasks/complete"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "userId": userId,
          "level": level,
          "tasks": taskData,
          "wellnessScore": wellnessScore,
          "dietScore": dietScore,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to complete level: ${response.statusCode}");
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/tasks/stats/$userId"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch user stats");
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}