import 'package:flutter/material.dart';

class IdCardScreen extends StatelessWidget {
  const IdCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student ID Card')),
      body: Center(
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                SizedBox(height: 16),
                Text(
                  'Student Name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Roll No: APJ2026'),
                SizedBox(height: 4),
                Text('Course: Computer Science'),
                SizedBox(height: 4),
                Text('Valid Till: 2026'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
