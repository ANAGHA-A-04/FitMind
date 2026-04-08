import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/checkin_model.dart';

class ApiService {

  // Change this to the IP of the machine running wellness_model/app.py
  static const String mlBaseUrl = "http://192.168.0.106:5002";

  // Send daily check-in data to ML backend and get prediction
  static Future<String?> getWellnessPrediction(CheckInModel checkin) async {
    try {
      final response = await http.post(
        Uri.parse("$mlBaseUrl/predict"),
        headers: {
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "steps": checkin.steps,
          "sleep": checkin.sleepHours,
          "stress": checkin.stressLevel,
          "mood": checkin.mood
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['mental_state'].toString();
        }
      } else {
        print("Error API: ${response.body}");
      }
      return null;
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }

}