import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Result'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events,
                    color: Colors.green, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'Congratulations!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('You have successfully completed the exam'),
                const SizedBox(height: 16),
                const Text(
                  'Score: 75 / 100',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  child: const Text('Back to Dashboard'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
