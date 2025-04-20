import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_cancer_detection_app/screens/uv_index/uv_index_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _showOnboarding = false;
  int _onboardingStep = 0;

  final List<String> onboardingTexts = [
    "By allowing us access to your camera you can take photos of your moles and skin conditions.",
    "Position your device's camera towards the area of your skin you want to capture.\n\nEnsure that the area is well-lit and in focus.",
    "Keep the mole in the centre and wait for the blue circle.\n\nOur smart camera will guide you to take the best quality picture."
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 2
          ? (_showOnboarding ? _buildOnboarding(context) : _buildPlaceholder())
          : _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            setState(() {
              _showOnboarding = true;
              _onboardingStep = 0;
              _currentIndex = index;
            });
          } else {
            setState(() {
              _currentIndex = index;
              _showOnboarding = false;
            });
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.accessibility), label: 'My body'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny), label: 'UV Index'),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz), label: 'Account'),
        ],
      ),
    );
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const MyBodyPage();
      case 3:
        return const UVIndexScreen();
      default:
        return const Center(child: Text("Page under construction"));
    }
  }

  Widget _buildPlaceholder() {
    return const Center(child: Text("Ready to scan..."));
  }

  Widget _buildOnboarding(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showOnboarding = false;
                });
              },
            ),
            title: const Text("Get started"),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          const SizedBox(height: 24),
          Image.asset(
            'lib/assets/images/onboarding${_onboardingStep + 1}.png',
            height: 240,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              onboardingTexts[_onboardingStep],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: () {
                if (_onboardingStep < onboardingTexts.length - 1) {
                  setState(() {
                    _onboardingStep++;
                  });
                } else {
                  setState(() {
                    _showOnboarding = false;
                  });
                  _showScanOptions(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.blue,
              ),
              child: const Text("Continue"),
            ),
          )
        ],
      ),
    );
  }

  void _showScanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                title: const Text('Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      debugPrint("📷 Picked image path: ${image.path}");
    }
  }
}

class MyBodyPage extends StatefulWidget {
  const MyBodyPage({super.key});

  @override
  State<MyBodyPage> createState() => _MyBodyPageState();
}

class _MyBodyPageState extends State<MyBodyPage> {
  Offset? selectedSpot;
  String displayName = 'User';

  @override
  void initState() {
    super.initState();
    _loadEmailName();
  }

  Future<void> _loadEmailName() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? 'user@example.com';
    final name = email.split('@').first;

    setState(() {
      displayName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Text(
                  displayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 10),
                const Text('| Find skin type | Find risk profile',
                    style: TextStyle(fontSize: 12)),
                const Spacer(),
              ],
            ),
          ),
          // UV Bilgilendirme
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.wb_sunny, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(
                  child: Text("Turn on the UV index to get local UV updates!"),
                ),
                TextButton(onPressed: null, child: Text("Turn on"))
              ],
            ),
          ),
          // Hatırlatıcı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text("Set Skin Check Reminder"),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Vücut Haritası
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTapDown: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final local = box.globalToLocal(details.globalPosition);
                    final dx = local.dx;
                    final dy = local.dy - 200;

                    if (dx > 60 && dx < 180 && dy > 40 && dy < 400) {
                      setState(() {
                        selectedSpot = Offset(dx, dy);
                      });
                    }
                  },
                  child: Image.asset(
                    'lib/assets/images/body.png',
                    width: 240,
                    fit: BoxFit.contain,
                  ),
                ),
                if (selectedSpot != null)
                  Positioned(
                    left: selectedSpot!.dx - 10,
                    top: selectedSpot!.dy + 200 - 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Front (1)",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 20),
                Text("Back (0)", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
