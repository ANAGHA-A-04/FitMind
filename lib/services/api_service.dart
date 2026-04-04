import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/checkin_model.dart';

class ApiService {

  // Change this to your computer IP
  static const String baseUrl = "http://192.168.0.104:5000/api";

  // Send daily check-in data to backend
  static Future<bool> saveCheckIn(CheckInModel checkin) async {
    try {

      final response = await http.post(
        Uri.parse("$baseUrl/checkin"),
        headers: {
          "Content-Type": "application/json"
        },
        body: jsonEncode(checkin.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Error: ${response.body}");
        return false;
      }

    } catch (e) {
      print("API Error: $e");
      return false;
    }
  }

}