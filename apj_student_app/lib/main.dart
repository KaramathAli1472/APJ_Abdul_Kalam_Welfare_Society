import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';  
import 'package:webview_flutter/webview_flutter.dart'; 

// 🔹 Screens
import 'screens/login/login_screen.dart';
import 'screens/registration/registration_form_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/exam/exam_screen.dart';
import 'screens/result/result_screen.dart';
import 'screens/id_card/id_card_screen.dart';
// ✅ SyllabusScreen import (jo maine diya tha)
import 'screens/Syllabus/syllabus_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationFormScreen(),
        '/dashboard': (context) => DashboardScreen(),

        // 📘 Existing routes
        '/exam': (context) => ExamScreen(),
        '/result': (context) => ResultScreen(),
        '/idcard': (context) => IdCardScreen(),

        // ✅ Working routes
        '/syllabus': (context) => SyllabusScreen(),  // NO const!
        '/notice': (context) => _ComingSoonScreen(title: 'Notifications'),
        '/profile': (context) => _ComingSoonScreen(title: 'Profile'),
      },
    );
  }
}

// 🔹 TEMP SCREEN
class _ComingSoonScreen extends StatelessWidget {
  final String title;
  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'This screen is under construction',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Coming soon...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
