import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Change this to your computer's local IP when testing on physical device
  // For emulator, use: Android - 10.0.2.2, iOS - localhost
  static const String baseUrl = 'http://10.184.213.220:5000/api';

// Register new user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required double weight,
    required double height,
    required String dateOfBirth,
    required String goal,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'weight': weight,
          'height': height,
          'dateOfBirth': dateOfBirth,
          'goal': goal,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
// Clear old user data first (in case of re-registration)
        await clearUserDataOnLogin();
        
// Save token to local storage
        if (data['data'] != null && data['data']['token'] != null) {
          await saveToken(data['data']['token']);
        }
// Save userId to local storage
        if (data['data'] != null && data['data']['user'] != null && data['data']['user']['id'] != null) {
          await saveUserId(data['data']['user']['id']);
        }
        return {
          'success': true,
          'message': data['message'],
          'user': data['data']['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Unable to connect to server. Make sure the backend is running.',
        'error': e.toString(),
      };
    }
  }

// Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
// Clear old user data first
        await clearUserDataOnLogin();
        
// Save token to local storage
        if (data['data'] != null && data['data']['token'] != null) {
          await saveToken(data['data']['token']);
        }
// Save userId to local storage
        if (data['data'] != null && data['data']['user'] != null && data['data']['user']['id'] != null) {
          await saveUserId(data['data']['user']['id']);
        }
        return {
          'success': true,
          'message': data['message'],
          'user': data['data']['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Unable to connect to server. Make sure the backend is running.',
        'error': e.toString(),
      };
    }
  }

// Save token to local storage
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

// Save userId to local storage
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

// Get token from local storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

// Get userId from local storage
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    print("📦 Retrieved userId from SharedPreferences: '$userId' (type: ${userId.runtimeType})");
    return userId;
  }

// Remove token (logout) - Clear ALL user data
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('userId');
    
    // Clear all user-specific SharedPreferences to prevent data leakage between users
    // Level-related data
    await prefs.remove('activeLevel');
    await prefs.remove('xp');
    await prefs.remove('level');
    await prefs.remove('lastCheckInDate');
    
    // Wellness check data (clear all levels)
    for (int i = 0; i <= 10; i++) {
      await prefs.remove('wellness_score_$i');
      await prefs.remove('wellness_done_$i');
      await prefs.remove('diet_score_$i');
      await prefs.remove('diet_done_$i');
    }
  }

// Clear user data on new login (prevent data leakage)
  static Future<void> clearUserDataOnLogin() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all user-specific SharedPreferences
    // Level-related data
    await prefs.remove('activeLevel');
    await prefs.remove('xp');
    await prefs.remove('level');
    await prefs.remove('lastCheckInDate');
    
    // Wellness check data (clear all levels)
    for (int i = 0; i <= 10; i++) {
      await prefs.remove('wellness_score_$i');
      await prefs.remove('wellness_done_$i');
      await prefs.remove('diet_score_$i');
      await prefs.remove('diet_done_$i');
    }
  }

// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}