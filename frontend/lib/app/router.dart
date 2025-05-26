import 'dart:io';
import 'package:go_router/go_router.dart';

import '../screens/onboarding/onboarding_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/scan/scan_select_screen.dart';
import '../screens/scan/detection_result_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/scan/camera_screen.dart';
import '../screens/scan/gallery_picker_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/scan-select',
      builder: (context, state) => const ScanSelectScreen(),
    ),
    GoRoute(
      path: '/camera',
      builder: (context, state) {
        final bodyPart = state.uri.queryParameters['bodyPart'] ?? '';
        return CameraScreen(bodyPart: bodyPart);
      },
    ),
    GoRoute(
      path: '/gallery-picker',
      builder: (context, state) => const GalleryPickerScreen(),
    ),
    GoRoute(
      path: '/detection-result',
      builder: (context, state) {
        final file = state.extra as File;
        return DetectionResultScreen(file: file);
      },
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings-screen',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
