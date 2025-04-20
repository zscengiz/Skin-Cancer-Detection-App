import 'package:flutter/material.dart';
import 'package:skin_cancer_detection_app/screens/auth/login_widget.dart';
import 'package:skin_cancer_detection_app/screens/auth/sign_up_widget.dart'
    as sign;
import 'package:skin_cancer_detection_app/screens/auth/forgot_password_widget.dart'
    as forgot;
import 'package:skin_cancer_detection_app/screens/home/home_page.dart'; // ← HomePage importu

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Cancer Detection App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginWidget(),
        '/signUp': (context) => const sign.SignUpWidget(),
        '/forgotPassword': (context) => const forgot.ForgotPasswordWidget(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
