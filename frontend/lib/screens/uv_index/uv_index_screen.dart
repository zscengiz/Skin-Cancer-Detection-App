import 'package:flutter/material.dart';
import 'package:location/location.dart';

class UVIndexScreen extends StatefulWidget {
  const UVIndexScreen({super.key});

  @override
  State<UVIndexScreen> createState() => _UVIndexScreenState();
}

class _UVIndexScreenState extends State<UVIndexScreen> {
  bool _showResult = false;
  bool _permissionDenied = false;

  double _uvIndex = 0;
  String _advice = "";
  String _uvLevel = "";
  String _date = "";

  Future<void> _getUVData() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _permissionDenied = true;
        });
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _permissionDenied = true;
        });
        return;
      }
    }

    final locData = await location.getLocation();

    // API ENTEGRASYONU BURAYA EKLENECEK
    // final uvData = await OpenWeatherAPI.getUV(lat: locData.latitude, lon: locData.longitude);

    setState(() {
      _uvIndex = 7.5; // gerçek API datası burada olacak
      _uvLevel = _getUVLevel(_uvIndex);
      _advice = _getAdvice(_uvIndex);
      _date =
          "${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}";
      _showResult = true;
    });
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _getUVLevel(double index) {
    if (index < 3) return "Low";
    if (index < 6) return "Moderate";
    if (index < 8) return "High";
    if (index < 11) return "Very High";
    return "Extreme";
  }

  String _getAdvice(double index) {
    if (index < 3) {
      return "Low risk. You can safely stay outside.";
    } else if (index < 6) {
      return "Moderate risk. Wear sunglasses and use SPF 15+ sunscreen.";
    } else if (index < 8) {
      return "High risk. Use SPF 30+ cream, sunglasses, and stay in the shade.";
    } else if (index < 11) {
      return "Very high risk. Avoid the sun during midday hours.";
    } else {
      return "Extreme risk. Stay indoors and avoid sun exposure.";
    }
  }

  String get _generalAdvice =>
      "☀️ Remember to protect your skin daily:\n\n• Use SPF 30+ sunscreen\n• Wear sunglasses\n• Stay in the shade during peak hours\n• Reapply sunscreen every 2 hours";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UV Index")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _permissionDenied
            ? _buildPermissionDeniedView()
            : _showResult
                ? _buildResultView()
                : _buildInitialView(),
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('lib/assets/images/uv_intro.png', height: 180),
        const SizedBox(height: 24),
        const Text(
          'UV Protection',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'By knowing your location we can tell you your daily local UV index so you can protect your skin',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _getUVData,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.blue,
          ),
          child: const Text("CONTINUE"),
        )
      ],
    );
  }

  Widget _buildResultView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("UV Index",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.wb_sunny, size: 36, color: Colors.amber),
            const SizedBox(width: 12),
            Text(
              _uvLevel,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text("Advice", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(_advice, style: const TextStyle(color: Colors.black87)),
        const SizedBox(height: 24),
        Text("Latest result", style: TextStyle(fontWeight: FontWeight.bold)),
        Text(_date),
        const SizedBox(height: 12),
        const Text("Source", style: TextStyle(fontWeight: FontWeight.bold)),
        const Text("OpenWeather"),
      ],
    );
  }

  Widget _buildPermissionDeniedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.warning_amber_rounded,
            color: Colors.redAccent, size: 64),
        const SizedBox(height: 24),
        const Text(
          'Location permission not granted',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          _generalAdvice,
          textAlign: TextAlign.left,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
