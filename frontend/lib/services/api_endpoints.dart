import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  static final String login = '$baseUrl/api/auth/login';
  static final String signup = '$baseUrl/api/auth/signup';
  static final String forgotPassword =
      '$baseUrl/api/auth/request-password-reset';
  static final String refreshToken = '$baseUrl/api/auth/refresh-token';
  static final String changePassword = '$baseUrl/api/auth/change-password';
  static final String updateProfile = '$baseUrl/api/auth/update-profile';

  static final String uploadReport = '$baseUrl/api/reports/upload';
  static final String getMyReports = '$baseUrl/api/reports/me';
  static String getImage(String reportId) =>
      '$baseUrl/api/reports/image/$reportId';
  static String getPdf(String reportId) => '$baseUrl/api/reports/pdf/$reportId';
}
