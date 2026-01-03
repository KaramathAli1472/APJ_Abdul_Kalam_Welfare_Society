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
      
      // Theme setup
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          accentColor: const Color(0xFF2196F3),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      
      // 🔐 App start hote hi LOGIN screen
      initialRoute: '/login',
      
      routes: {
        // 🔑 Login Screen - WITHOUT const (StatefulWidget)
        '/login': (context) => LoginScreen(),
        
        // 📝 Login/Google Sign-in ke baad Registration Form
        '/register': (context) => RegistrationFormScreen(),
        
        // 🏠 Registration submit ke baad Dashboard - WITHOUT const (StatefulWidget)
        '/dashboard': (context) => DashboardScreen(),
        
        // 📚 Other screens - WITHOUT const
        '/exam': (context) => ExamScreen(),
        '/result': (context) => ResultScreen(),
        '/idcard': (context) => IdCardScreen(),
      },
    );
  }
}
