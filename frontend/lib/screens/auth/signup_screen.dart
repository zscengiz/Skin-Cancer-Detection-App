import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  final List<String> allowedDomains = [
    'gmail.com',
    'hotmail.com',
    'outlook.com',
    'icloud.com',
    'yahoo.com',
    'edu.tr',
    'edu.com',
    'bilkent.edu.tr',
    'hacettepe.edu.tr',
    'ostimteknik.edu.tr',
  ];

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final domain = email.split('@').last.toLowerCase();
    return regex.hasMatch(email) &&
        allowedDomains.any((d) => domain == d || domain.endsWith(d));
  }

  bool _isValidPassword(String password) {
    final length = RegExp(r'.{8,}');
    final upper = RegExp(r'[A-Z]');
    final lower = RegExp(r'[a-z]');
    final number = RegExp(r'\d');
    final special = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    return length.hasMatch(password) &&
        upper.hasMatch(password) &&
        lower.hasMatch(password) &&
        number.hasMatch(password) &&
        special.hasMatch(password);
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: 'Please fix the errors above');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.signup(
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      Fluttertoast.showToast(msg: 'Signup successful! Logging in...');

      final loginResponse = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'access_token', loginResponse['access_token'] ?? '');
      await prefs.setString(
          'refresh_token', loginResponse['refresh_token'] ?? '');
      await prefs.setString('user_email', _emailController.text.trim());
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('user_surname', _surnameController.text.trim());

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      final msg = _extractErrorMessage(e);
      Fluttertoast.showToast(msg: msg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _extractErrorMessage(dynamic error) {
    try {
      if (error is Exception && error.toString().contains('Exception:')) {
        return error.toString().replaceFirst('Exception: ', '');
      }
      return error.toString();
    } catch (_) {
      return 'Signup failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Create an Account',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().length < 3) {
                              return 'Name must be at least 3 characters.';
                            }
                            if (!RegExp(r'^[a-zA-ZğüşöçıİĞÜŞÖÇ\s]+$')
                                .hasMatch(value)) {
                              return 'Name must contain only letters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _surnameController,
                          decoration: const InputDecoration(
                            labelText: 'Surname',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().length < 3) {
                              return 'Surname must be at least 3 characters.';
                            }
                            if (!RegExp(r'^[a-zA-ZğüşöçıİĞÜŞÖÇ\s]+$')
                                .hasMatch(value)) {
                              return 'Surname must contain only letters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || !_isValidEmail(value)) {
                              return 'Enter a valid email with approved domain.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || !_isValidPassword(value)) {
                              return 'Password must be 8+ chars, include upper/lower case, number & special char.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _handleSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
