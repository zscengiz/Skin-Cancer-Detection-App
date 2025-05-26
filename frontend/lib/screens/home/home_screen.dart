import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  int _selectedIndex = 0;
  final PageController _cameraTipsController = PageController();
  final List<String> _routes = [
    '/home',
    '/reports',
    '/scan-select',
    '/profile',
    '/settings-screen'
  ];
  double? uvIndex;
  String uvIconPath = 'assets/images/cloud.png';
  bool _isLoadingUV = true;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _determinePosition().then((position) => _fetchUVIndex(position));
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);
      setState(() {
        userName = decoded['name'] ?? '';
        _isLoadingUser = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) await Geolocator.openLocationSettings();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Konum izni kalıcı olarak reddedildi.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _fetchUVIndex(Position position) async {
    final lat = position.latitude;
    final lon = position.longitude;
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    final url =
        'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,daily,alerts&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final uv = data['current']['uvi'];
      String icon;
      if (uv <= 2) {
        icon = 'assets/images/cloud.png';
      } else if (uv <= 5) {
        icon = 'assets/images/sun_behind_cloud.png';
      } else if (uv <= 7) {
        icon = 'assets/images/sun.png';
      } else if (uv <= 10) {
        icon = 'assets/images/sun_bright.png';
      } else {
        icon = 'assets/images/sun_warning.png';
      }
      setState(() {
        uvIndex = uv.toDouble();
        uvIconPath = icon;
        _isLoadingUV = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    context.go(index == 2 ? '/scan-select' : _routes[index]);
  }

  Color _getIconColor(int index, bool isDark) {
    if (_selectedIndex == index) {
      return isDark ? Colors.blueAccent : Colors.blueAccent;
    } else {
      return isDark ? Colors.white70 : Colors.black;
    }
  }

  Color _getUVBoxColor(double uv, bool isDark) {
    if (isDark) return Colors.grey[850]!;
    if (uv <= 2) return Colors.green[200]!;
    if (uv <= 5) return Colors.yellow[200]!;
    if (uv <= 7) return Colors.orange[200]!;
    if (uv <= 10) return Colors.red[200]!;
    return Colors.purple[200]!;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateTime.now();
    final formattedDate = "${date.day}/${date.month}/${date.year}";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/images/profilePlaceholder.png'),
                ),
                const SizedBox(width: 10),
                _isLoadingUser
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                            width: 80, height: 20, color: Colors.white),
                      )
                    : Text(
                        'Hi, $userName',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : null),
                      ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _infoBoxImage(
                    imagePath: 'assets/images/calendar.png',
                    title: "Today",
                    value: formattedDate,
                    backgroundColor:
                        isDark ? Colors.grey[850]! : const Color(0xFFE0F2FE),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isLoadingUV
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        )
                      : _infoBoxImage(
                          imagePath: uvIconPath,
                          title: "UV Index",
                          value: uvIndex!.toStringAsFixed(1),
                          backgroundColor: _getUVBoxColor(uvIndex!, isDark),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _infoCard("Check your moles regularly.",
                "assets/images/skinProtection.png", isDark),
            const SizedBox(height: 12),
            _infoCard(
                "Use sunscreen daily.", "assets/images/sunCream.png", isDark),
            const SizedBox(height: 12),
            _infoCard("Consult a doctor for odd spots.",
                "assets/images/hospital.png", isDark),
            const SizedBox(height: 12),
            _infoCard("Avoid excessive sun exposure.",
                "assets/images/sunProtection.png", isDark),
            const SizedBox(height: 12),
            _infoCard("Stay hydrated.", "assets/images/pill.png", isDark),
            const SizedBox(height: 30),
            Text(
              "Camera Tips",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: PageView(
                controller: _cameraTipsController,
                children: [
                  _cameraTip("Take photos in bright lighting.",
                      "assets/images/light.png", isDark),
                  _cameraTip("Center the mole in the square.",
                      "assets/images/center.png", isDark),
                  _cameraTip(
                      "Hold phone steady", "assets/images/steady.png", isDark),
                  _cameraTip("Don’t use filters or flash.",
                      "assets/images/flash.png", isDark),
                  _cameraTip("Avoid blurry or angled shots.",
                      "assets/images/blurry.png", isDark),
                  _cameraTip("Keep the area clean and dry.",
                      "assets/images/clean.png", isDark),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                icon: Icon(Icons.home, color: _getIconColor(0, isDark)),
                onPressed: () => _onItemTapped(0)),
            IconButton(
                icon: Icon(Icons.history, color: _getIconColor(1, isDark)),
                onPressed: () => _onItemTapped(1)),
            const SizedBox(width: 48),
            IconButton(
                icon: Icon(Icons.person, color: _getIconColor(3, isDark)),
                onPressed: () => _onItemTapped(3)),
            IconButton(
                icon: Icon(Icons.settings, color: _getIconColor(4, isDark)),
                onPressed: () => _onItemTapped(4)),
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

  Widget _infoBoxImage({
    required String imagePath,
    required String title,
    required String value,
    required Color backgroundColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 32, height: 32, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 14, color: isDark ? Colors.white70 : Colors.grey)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.blueAccent,
              )),
        ],
      ),
    );
  }

  Widget _infoCard(String text, String imagePath, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.amber[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 48, height: 48),
          const SizedBox(width: 16),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black),
                  textAlign: TextAlign.left)),
        ],
      ),
    );
  }

  Widget _cameraTip(String tip, String imagePath, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 40, height: 40),
          const SizedBox(width: 16),
          Expanded(
              child: Text(tip,
                  style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black),
                  textAlign: TextAlign.left)),
        ],
      ),
    );
  }
}
