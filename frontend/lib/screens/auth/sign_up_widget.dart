import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:skin_cancer_detection_app/models/sign_up_model.dart';
import 'package:skin_cancer_detection_app/services/api_service.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final _model = SignUpModel();

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_model.formKey.currentState!.validate()) return;

    final email = _model.emailController.text.trim();
    final password = _model.passwordController.text.trim();

    try {
      final response = await ApiService.register(email, password);

      if (response.statusCode == 201) {
        _showSnack("Registration successful!");
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final error = jsonDecode(response.body);
        _showSnack(error['detail'] ?? 'Registration failed', isError: true);
      }
    } catch (e) {
      _showSnack("Server error. Please try again.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _model.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('lib/assets/images/logo.png', height: 64),
                const SizedBox(height: 24),
                const Text(
                  'Sign Up For Free.',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const Text(
                  'Create an account so you can explore.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _model.emailController,
                  focusNode: _model.emailFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: _model.emailValidator,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _model.passwordController,
                  focusNode: _model.passwordFocusNode,
                  obscureText: !_model.passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _model.passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _model.passwordVisible = !_model.passwordVisible;
                        });
                      },
                    ),
                  ),
                  validator: _model.passwordValidator,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _model.rememberMe,
                      onChanged: (val) {
                        setState(() => _model.rememberMe = val!);
                      },
                    ),
                    const Text('Remember me'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgotPassword');
                      },
                      child: const Text('Forgot password?'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Already have an account? Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
