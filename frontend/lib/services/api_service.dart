import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //static const String baseUrl = 'http://localhost:8000'; //chrome için
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  static Future<http.Response> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  static Future<http.Response> requestPasswordReset(String email) async {
    final url = Uri.parse('$baseUrl/auth/request-password-reset');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: '"$email"',
    );
  }

  static Future<http.Response> resetPassword(
      String email, String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'token': token,
        'new_password': newPassword,
      }),
    );
  }
}
