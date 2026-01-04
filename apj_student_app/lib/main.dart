import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// 🔹 Screens
import 'screens/login/login_screen.dart';
import 'screens/registration/registration_form_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/exam/exam_screen.dart';
import 'screens/result/result_screen.dart';
import 'screens/id_card/id_card_screen.dart';

// ⚠️ NOTE:
// syllabus / notice / profile screens abhi create nahi hui
// isliye abhi import NAHI kar rahe

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase initialization
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

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
        ),
        fontFamily: 'Roboto',
      ),

      // 🔐 Start screen
      initialRoute: '/login',

      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationFormScreen(),
        '/dashboard': (context) => DashboardScreen(),

        // 📘 Existing routes
        '/exam': (context) => ExamScreen(),
        '/result': (context) => ResultScreen(),
        '/idcard': (context) => IdCardScreen(),

        // 🚧 TEMP PLACEHOLDER ROUTES (NO ERROR)
        '/syllabus': (context) => _ComingSoonScreen(title: 'Syllabus'),
        '/notice': (context) => _ComingSoonScreen(title: 'Notice'),
        '/profile': (context) => _ComingSoonScreen(title: 'Profile'),
      },
    );
  }
}

// 🔹 TEMP SCREEN (jab tak real screen na bane)
class _ComingSoonScreen extends StatelessWidget {
  final String title;
  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title screen coming soon',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
