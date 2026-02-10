import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // Pull the URL from your .env file
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';

  /// REGISTER USER
  Future<bool> signUp(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password.trim(),
        }),
      );

      // Return true if the backend returns 201 (Created) or 200 (OK)
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Sign Up Error: $e");
      return false;
    }
  }

  /// LOGIN USER
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'), // Ensure this matches your backend route
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password.trim(),
        }),
      );

      if (response.statusCode == 200) {
        // Here you would typically save the JWT token using flutter_secure_storage
        // final data = jsonDecode(response.body);
        // String token = data['token'];
        return true;
      }
      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }
}