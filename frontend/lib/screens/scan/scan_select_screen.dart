import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ScanSelectScreen extends StatefulWidget {
  const ScanSelectScreen({super.key});

  @override
  State<ScanSelectScreen> createState() => _ScanSelectScreenState();
}

class _ScanSelectScreenState extends State<ScanSelectScreen> {
  final List<Map<String, dynamic>> bodyParts = [
    {'name': 'Head', 'icon': LucideIcons.user},
    {'name': 'Body', 'icon': LucideIcons.personStanding},
    {'name': 'Left Arm', 'icon': LucideIcons.arrowLeftCircle},
    {'name': 'Right Arm', 'icon': LucideIcons.arrowRightCircle},
    {'name': 'Left Leg', 'icon': LucideIcons.arrowDownLeft},
    {'name': 'Right Leg', 'icon': LucideIcons.arrowDownRight},
  ];

  String selectedPart = '';
  bool showModal = false;

  void _selectPart(String part) {
    setState(() {
      selectedPart = part;
      showModal = true;
    });
  }

  void _handleOptionSelect(String option) {
    setState(() => showModal = false);

    final encodedPart = Uri.encodeComponent(selectedPart);
    switch (option) {
      case 'Camera':
        context.go('/camera?bodyPart=$encodedPart');
        break;
      case 'Gallery':
        context.go('/gallery-picker?bodyPart=$encodedPart');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF0F6FF);
    final cardColor = isDark ? Colors.grey[850] : const Color(0xFFFFF3CD);
    final textColor = isDark ? Colors.white : const Color(0xFF4991FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bgColor,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: textColor,
              onPressed: () => context.go('/home'),
              tooltip: 'Go to Home',
            ),
            const SizedBox(width: 8),
            Text(
              'Select Scan Area',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tap on a body part",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: bodyParts.map((part) {
                      return InkWell(
                        onTap: () => _selectPart(part['name']),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(part['icon'],
                                  size: 40, color: Colors.blue.shade800),
                              const SizedBox(height: 10),
                              Text(
                                part['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (showModal)
            GestureDetector(
              onTap: () => setState(() => showModal = false),
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: ['Camera', 'Gallery', 'Cancel'].map((label) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          onPressed: () {
                            if (label == 'Cancel') {
                              setState(() => showModal = false);
                            } else {
                              _handleOptionSelect(label);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: label == 'Cancel'
                                ? Colors.grey.shade300
                                : Colors.blueAccent,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: label == 'Cancel'
                                  ? Colors.black87
                                  : Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
