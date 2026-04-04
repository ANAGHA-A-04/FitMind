import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  // Update this IP to your computer's local IP address
  // Find it by running: ipconfig (Windows) or ifconfig (Mac/Linux)
  static const String baseUrl = 'http://192.168.0.104:5001';

  /// Send a message to the FitMind chatbot and get a response
  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Please check if the chatbot server is running.');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'Sorry, I could not understand that.';
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        return data['error'] ?? 'Invalid request.';
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Return user-friendly error message
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused')) {
        return 'Connection error. Please make sure the chatbot server is running on your computer.';
      }
      return 'Error: ${e.toString()}';
    }
  }

  /// Check if the chatbot server is running
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
