import 'dart:convert';
import 'package:http/http.dart' as http;

class WellnessService {
  // Pointing to the Python Flask Server running the wellness_model
  // For physical device testing, change to your PC's IP
  static const String pythonModelUrl = "http://192.168.43.130:5002";

  /// Send user check-in data to the Python AI model to predict wellness state
  /// mood is a string: "Happy", "Neutral", "Sad", "Stressed"
  static Future<String> getWellnessPrediction(int steps, double sleep, double stress, String mood) async {
    try {
      final response = await http.post(
        Uri.parse('$pythonModelUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'steps': steps,
          'sleep': sleep,
          'stress': stress,
          'mood': mood,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['mental_state'].toString();
        }
      }
      return 'Balanced'; // Fallback state
    } catch (e) {
      print("Error calling wellness model: $e");
      return 'Balanced'; // Fallback if server is not running
    }
  }

  /// Send check-in data to get the lifestyle cluster label
  /// Returns one of: "High-Energy Achiever", "Stressed Overworker", "Sedentary/Relaxed"
  static Future<String> getLifestyleCluster(int steps, double sleep, double stress, double mood, int calories) async {
    try {
      final response = await http.post(
        Uri.parse('$pythonModelUrl/predict_cluster'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'steps': steps,
          'sleep': sleep,
          'stress': stress,
          'mood': mood,
          'calories': calories,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['lifestyle_cluster'].toString();
        }
      }
      return 'Balanced Lifestyle'; // Fallback
    } catch (e) {
      print("Error calling cluster model: $e");
      return 'Balanced Lifestyle'; // Fallback if server is not running
    }
  }
}
