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
      _loadUserFromToken();

      setState(() {
        isEditingName = false;
        isEditingSurname = false;
        isEditingEmail = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating profile')),
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
              if (choice == 'Change') {
                onChange();
              } else if (choice == 'Cancel') {
                onCancel();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (!isEditing)
                const PopupMenuItem<String>(
                  value: 'Change',
                  child: Text('Change'),
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
                tooltip: 'Go to Home',
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
                title: "Name",
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
                title: "Surname",
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
                    _updateProfileField(
                      nameController.text,
                      surnameController.text,
                      emailController.text,
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
                    'Save Changes',
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
