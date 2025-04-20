import 'package:flutter/material.dart';

class SignUpModel {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordController = TextEditingController();
  final passwordFocusNode = FocusNode();
  bool passwordVisible = false;
  bool rememberMe = true;

  String? emailValidator(String? val) {
    if (val == null || val.isEmpty) return 'Email required';

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(val)) return 'Invalid email format';

    final allowedDomains = [
      'gmail.com',
      'hotmail.com',
      'outlook.com',
      'icloud.com',
      'yahoo.com',
      'edu.tr',
      'edu.com',
      'bilkent.edu.tr',
      'hacettepe.edu.tr',
      'ostimteknik.edu.tr'
    ];

    final domain = val.split('@').last.toLowerCase();
    final isDomainAllowed =
        allowedDomains.any((d) => domain == d || domain.endsWith(d));

    if (!isDomainAllowed) {
      return 'Email must be from an approved institution or provider.';
    }

    return null;
  }

  String? passwordValidator(String? val) {
    if (val == null || val.isEmpty) return 'Password required';
    if (val.length < 6) return 'Minimum 6 characters';
    return null;
  }

  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
  }
}
