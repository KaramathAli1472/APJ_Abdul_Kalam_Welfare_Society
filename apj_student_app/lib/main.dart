import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Screens
import 'screens/login/login_screen.dart';
import 'screens/registration/registration_form_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/exam/exam_screen.dart';
import 'screens/result/result_screen.dart';
import 'screens/id_card/id_card_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase initialization (ERROR FIX)
  await Firebase.initializeApp();

  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APJ Student App',
      debugShowCheckedModeBanner: false,

      // 🔐 App start hote hi LOGIN screen
      initialRoute: '/login',

      routes: {
        // 🔑 Login Screen
        '/login': (context) => const LoginScreen(),

        // 📝 Login ke baad Registration Form
        '/register': (context) => const RegistrationFormScreen(),

        // 🏠 Registration submit ke baad Dashboard
        '/dashboard': (context) => const DashboardScreen(),

        // 📚 Other screens
        '/exam': (context) => const ExamScreen(),
        '/result': (context) => const ResultScreen(),
        '/idcard': (context) => const IdCardScreen(),
      },
    );
  }
}
