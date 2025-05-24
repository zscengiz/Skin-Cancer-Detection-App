import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  static final String login = '$baseUrl/api/auth/login';
  static final String signup = '$baseUrl/api/auth/signup';
  static final String forgotPassword =
      '$baseUrl/api/auth/request-password-reset';
  static final String refreshToken = '$baseUrl/api/auth/refresh-token';
  static final String uploadReport = '$baseUrl/api/upload';
}
