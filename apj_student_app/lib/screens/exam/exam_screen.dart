import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _secondsRemaining = 60 * 30; // 30 minutes

  @override
  void initState() {
    super.initState();

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      WakelockPlus.enable();
    }

    _startTimer();
  }

  void _startTimer() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    if (_secondsRemaining > 0) {
      setState(() => _secondsRemaining--);
      _startTimer();
    } else {
      _submitExam();
    }
  }

  void _submitExam() {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      WakelockPlus.disable();
    }

    Navigator.pushReplacementNamed(context, '/result');
  }

  @override
  void dispose() {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      WakelockPlus.disable();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Exam'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Time Remaining',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '$minutes:$seconds',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submitExam,
              child: const Text('Submit Exam'),
            )
          ],
        ),
      ),
    );
  }
}
