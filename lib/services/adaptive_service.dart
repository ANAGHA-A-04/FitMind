import 'dart:convert';
import 'package:http/http.dart' as http;

class AdaptiveService {
  static const String baseUrl = "http://192.168.43.12:5004";

  static Future<Map<String, dynamic>> generateTasks({
    required String userId,
    required int wellnessScore,
    required int dietScore,
  }) async {
    try {
      print("\n=== ADAPTIVE SERVICE DEBUG ===");
      print("📤 Sending userId: '$userId' (type: ${userId.runtimeType}, length: ${userId.length})");
      print("📤 Sending wellnessScore: $wellnessScore");
      print("📤 Sending dietScore: $dietScore");
      
      final requestBody = {
        "userId": userId,
        "wellnessScore": wellnessScore,
        "dietScore": dietScore,
      };
      
      print("📦 Request Body: $requestBody");
      print("🌐 Endpoint: $baseUrl/generate_tasks");
      print("============================\n");

      final response = await http.post(
        Uri.parse("$baseUrl/generate_tasks"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      print("✅ Status Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["status"] == "success") {
        return data;
      } else {
        throw Exception(data["message"] ?? "Task generation failed");
      }
    } catch (e) {
      print("❌ ADAPTIVE ENGINE ERROR: $e");
      throw Exception("Adaptive engine error: $e");
    }
  }
}