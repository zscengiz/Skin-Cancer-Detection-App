import 'package:flutter/material.dart';

class LoginModel {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordController = TextEditingController();
  final passwordFocusNode = FocusNode();
  bool passwordVisible = false;

  String? emailValidator(String? val) {
    if (val == null || val.isEmpty) return 'Email required';
    if (!val.contains('@')) return 'Invalid email';
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
