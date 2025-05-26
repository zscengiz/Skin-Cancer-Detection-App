import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String surname = '';
  String email = '';

  bool isEditingName = false;
  bool isEditingSurname = false;
  bool isEditingEmail = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserFromToken();
  }

  Future<void> _loadUserFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);
      setState(() {
        name = decoded['name'] ?? '';
        surname = decoded['surname'] ?? '';
        email = decoded['sub'] ?? '';
        nameController.text = name;
        surnameController.text = surname;
        emailController.text = email;
      });
    }
  }

  String? _validateName(String value) {
    if (value.trim().isEmpty) return 'Name cannot be empty';
    if (value.length < 3) return 'Name must be at least 3 characters';
    if (!RegExp(r"^[a-zA-ZğüşöçıİĞÜŞÖÇ\s]+$").hasMatch(value)) {
      return 'Name must contain only letters';
    }
    return null;
  }

  String? _validateSurname(String value) {
    if (value.trim().isEmpty) return 'Surname cannot be empty';
    if (value.length < 3) return 'Surname must be at least 3 characters';
    if (!RegExp(r"^[a-zA-ZğüşöçıİĞÜŞÖÇ\s]+$").hasMatch(value)) {
      return 'Surname must contain only letters';
    }
    return null;
  }

  String? _validateEmail(String value) {
    if (value.trim().isEmpty) return 'Email cannot be empty';
    if (!RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  Future<void> _updateProfileField(
      String updatedName, String updatedSurname, String updatedEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/auth/update-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': updatedName,
        'surname': updatedSurname,
        'email': updatedEmail,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      await prefs.setString('access_token', data['access_token']);
      await prefs.setString('refresh_token', data['refresh_token']);
      await _loadUserFromToken();

      setState(() {
        isEditingName = false;
        isEditingSurname = false;
        isEditingEmail = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: const Color(0xFFD4EDDA),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      );
    } else {
      final error = jsonDecode(response.body)['detail'] ?? 'An error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update error: $error')),
      );
    }
  }

  Widget _buildEditableField({
    required String title,
    required String value,
    required bool isEditing,
    required TextEditingController controller,
    required VoidCallback onChange,
    required VoidCallback onCancel,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: title,
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 10),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                color: isDark ? Colors.white70 : Colors.black54),
            onSelected: (String choice) {
              if (choice == 'Edit') {
                onChange();
              } else if (choice == 'Cancel') {
                onCancel();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (!isEditing)
                const PopupMenuItem<String>(
                  value: 'Edit',
                  child: Text('Edit'),
                ),
              if (isEditing)
                const PopupMenuItem<String>(
                  value: 'Cancel',
                  child: Text('Cancel'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    context.go('/home');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF0F6FF),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: isDark ? Colors.black : const Color(0xFFF0F6FF),
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                color: isDark ? Colors.white : const Color(0xFF4991FF),
                onPressed: () => context.go('/home'),
                tooltip: 'Home',
              ),
              const SizedBox(width: 8),
              Text(
                'Profile',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF4991FF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildEditableField(
                title: "First Name",
                value: name,
                isEditing: isEditingName,
                controller: nameController,
                onChange: () => setState(() => isEditingName = true),
                onCancel: () => setState(() {
                  isEditingName = false;
                  nameController.text = name;
                }),
              ),
              _buildEditableField(
                title: "Last Name",
                value: surname,
                isEditing: isEditingSurname,
                controller: surnameController,
                onChange: () => setState(() => isEditingSurname = true),
                onCancel: () => setState(() {
                  isEditingSurname = false;
                  surnameController.text = surname;
                }),
              ),
              _buildEditableField(
                title: "Email",
                value: email,
                isEditing: isEditingEmail,
                controller: emailController,
                onChange: () => setState(() => isEditingEmail = true),
                onCancel: () => setState(() {
                  isEditingEmail = false;
                  emailController.text = email;
                }),
              ),
              const SizedBox(height: 36),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final nameError = _validateName(nameController.text.trim());
                    final surnameError =
                        _validateSurname(surnameController.text.trim());
                    final emailError =
                        _validateEmail(emailController.text.trim());

                    if (nameError != null ||
                        surnameError != null ||
                        emailError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(nameError ?? surnameError ?? emailError!),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    _updateProfileField(
                      nameController.text.trim(),
                      surnameController.text.trim(),
                      emailController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.white : const Color(0xFF4991FF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
