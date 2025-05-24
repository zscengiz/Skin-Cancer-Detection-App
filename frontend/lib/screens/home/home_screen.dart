import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  String weatherIcon = 'sun';
  final double uvIndex = 5.2;

  final List<String> _routes = [
    '/home',
    '/reports',
    '/scan-select',
    '/profile',
    '/settings'
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _randomizeWeather();
  }

  void _randomizeWeather() {
    final options = ['sun', 'cloud', 'rain'];
    setState(() {
      weatherIcon = options[Random().nextInt(3)];
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);
      setState(() {
        userName = decoded['name'] ?? '';
      });
    }
  }

  ImageProvider getWeatherImage() {
    switch (weatherIcon) {
      case 'cloud':
        return const AssetImage('assets/images/cloud.png');
      case 'rain':
        return const AssetImage('assets/images/rain.png');
      case 'sun':
      default:
        return const AssetImage('assets/images/sun.png');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      context.go('/scan-select');
    } else {
      context.go(_routes[index]);
    }
  }

  Color _getIconColor(int index) {
    return _selectedIndex == index ? Colors.blueAccent : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      AssetImage('assets/images/profilePlaceholder.png'),
                ),
                const SizedBox(width: 12),
                Text(
                  userName.isNotEmpty ? 'Hi, $userName' : 'Hi',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(image: getWeatherImage(), width: 64, height: 64),
                  const SizedBox(height: 12),
                  const Text(
                    'Current UV Index',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    uvIndex.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: _getIconColor(0)),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.history, color: _getIconColor(1)),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: Icon(Icons.person, color: _getIconColor(3)),
              onPressed: () => _onItemTapped(3),
            ),
            IconButton(
              icon: Icon(Icons.settings, color: _getIconColor(4)),
              onPressed: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
