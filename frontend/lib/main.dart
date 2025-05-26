import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const SkinCancerApp());
}

class SkinCancerApp extends StatelessWidget {
  const SkinCancerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            themeMode: themeProvider.themeMode,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
          );
        },
      ),
    );
  }
}
