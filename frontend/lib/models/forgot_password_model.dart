import 'package:flutter/material.dart';

class ForgotPasswordModel {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();

  String? emailValidator(String? val) {
    if (val == null || val.isEmpty) return 'Email required';
    if (!val.contains('@')) return 'Invalid email';
    return null;
  }

  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
  }
}
