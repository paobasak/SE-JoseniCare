import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // IMPORTANT: Replace with your actual server URL
  // For local development with phpMyAdmin:
  // - If testing on physical Android device: use your computer's IP (e.g., 'http://192.168.1.100:8080')
  // - If testing on Android emulator: use 'http://10.0.2.2:8080'
  // - If testing on iOS simulator: use 'http://localhost:8080' or 'http://127.0.0.1:8080'
  // - If testing on web: use 'http://localhost:8080'
  static const String baseUrl = 'http://localhost:8080/SE-JoseniCare/backend/api';
  
  // Login endpoint
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Unknown error occurred',
        'data': data['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }

  // Signup endpoint
  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Unknown error occurred',
        'data': data['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }
}
