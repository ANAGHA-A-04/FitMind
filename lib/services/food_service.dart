import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FoodService {
  static const String baseUrl = "http://10.184.213.220:5002/api";

  // ✅ IMAGE ANALYSIS (MISSING FUNCTION FIX)
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

  // ✅ MANUAL FOOD (you already have this)
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
}