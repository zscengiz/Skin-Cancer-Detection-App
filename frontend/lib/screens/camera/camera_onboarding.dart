import 'package:flutter/material.dart';
import 'package:skin_cancer_detection_app/screens/camera/camera_options_dialog.dart';

class CameraOnboardingScreen extends StatefulWidget {
  const CameraOnboardingScreen({super.key});

  @override
  State<CameraOnboardingScreen> createState() => _CameraOnboardingScreenState();
}

class _CameraOnboardingScreenState extends State<CameraOnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> images = [
    'lib/assets/images/onboard1.png',
    'lib/assets/images/onboard2.png',
    'lib/assets/images/onboard3.png',
  ];

  final List<String> titles = [
    'Take photos',
    'The camera is automatic',
    'Keep the mole in the centre',
  ];

  final List<String> descriptions = [
    'By allowing us access to your camera you can take photos of your moles and skin conditions.',
    'Ensure that the area is well-lit and in focus. Smart camera helps guide the picture.',
    'Keep the mole in the centre and follow the blue ring instructions for best quality.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (value) => setState(() => _currentPage = value),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(images[index], height: 200),
                    const SizedBox(height: 32),
                    Text(titles[index],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(descriptions[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        if (index == images.length - 1) {
                          Navigator.pop(context);
                          showCameraOptions(context);
                        } else {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease);
                        }
                      },
                      child: const Text('Continue'),
                    )
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                showCameraOptions(context);
              },
              child: const Icon(Icons.close, size: 28),
            ),
          )
        ],
      ),
    );
  }
}
