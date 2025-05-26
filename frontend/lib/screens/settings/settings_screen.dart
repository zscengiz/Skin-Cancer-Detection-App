import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/theme/theme_provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Light mode renkleri
    const lightBgColor = Color(0xFFF0F6FF);
    const lightTextColor = Color(0xFF4991FF);

    // Dark mode renkleri
    const darkTextColor = Colors.white;
    const darkBgColor = Colors.black;

    return Scaffold(
      backgroundColor: isDark ? darkBgColor : lightBgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? darkBgColor : lightBgColor,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: isDark ? darkTextColor : lightTextColor,
              onPressed: () => context.go('/home'),
              tooltip: 'Go to Home',
            ),
            const SizedBox(width: 8),
            Text(
              'Settings',
              style: TextStyle(
                color: isDark ? darkTextColor : lightTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.dark_mode,
                color: isDark ? darkTextColor : lightTextColor),
            title: Text(
              'Dark Mode',
              style: TextStyle(
                  color: isDark ? darkTextColor : lightTextColor,
                  fontWeight: FontWeight.w500),
            ),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              activeColor: lightTextColor,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
          ),
        ],
      ),
    );
  }
}
