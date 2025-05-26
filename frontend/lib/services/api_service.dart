import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';
import '../models/report_model.dart';

class ApiService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.signup),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'surname': surname,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Signup failed');
    }
  }

  static Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.forgotPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Failed to send reset link');
    }
  }

  static Future<bool> refresh(String refreshToken) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.refreshToken),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access_token']);
      await prefs.setString('refresh_token', data['refresh_token']);
      return true;
    } else {
      return false;
    }
  }

  static Future<void> updateProfile({
    required String name,
    required String surname,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}/api/auth/update-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'surname': surname,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      await prefs.setString('access_token', data['access_token']);
      await prefs.setString('refresh_token', data['refresh_token']);
    } else {
      final detail = jsonDecode(response.body)['detail'] ?? 'Unknown error';
      throw Exception('Update failed: $detail');
    }
  }

  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final token = await getAccessToken();
    final response = await http.post(
      Uri.parse(ApiEndpoints.changePassword),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_new_password': confirmNewPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Password change failed');
    }
  }

  static Future<void> uploadReport({
    required File imageFile,
    required File pdfFile,
    required String label,
    required double confidence,
    required String riskLevel,
    required String advice,
  }) async {
    final uri = Uri.parse(ApiEndpoints.uploadReport);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['label'] = label
      ..fields['confidence'] = confidence.toString()
      ..fields['risk_level'] = riskLevel
      ..fields['advice'] = advice
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path))
      ..files.add(await http.MultipartFile.fromPath('pdf', pdfFile.path));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to upload report');
    }
  }

  static Future<List<ReportModel>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final response = await http.get(
      Uri.parse(ApiEndpoints.getMyReports),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> jsonList = data['data'];
      return jsonList.map((json) => ReportModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch reports');
    }
  }

  static Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  static Future<Map<String, String>> authHeader() async {
    final token = await getAccessToken();
    return {'Authorization': 'Bearer $token'};
  }
}
