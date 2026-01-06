import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  bool isLoading = true;

  String examId = '';
  String examName = '';
  int durationMinutes = 0;

  List<Map<String, dynamic>> questions = [];
  Map<int, String> selectedAnswers = {};

  int currentIndex = 0;
  int secondsRemaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  // ================= LOAD EXAM =================
  Future<void> _loadExam() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('exams')
          .where('deleted', isEqualTo: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        throw Exception('No exam found');
      }

      final doc = snap.docs.first;
      final data = doc.data();

      examId = doc.id;
      examName = data['examName'] ?? 'Exam';
      durationMinutes = (data['duration'] ?? 30).toInt();

      final List rawQuestions = data['questions'] ?? [];
      questions = rawQuestions
          .map((q) => Map<String, dynamic>.from(q))
          .toList();

      secondsRemaining = durationMinutes * 60;

      WakelockPlus.enable();
      _startTimer();

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('❌ Exam load error: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No exam available')),
      );
      Navigator.pop(context);
    }
  }

  // ================= TIMER =================
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining <= 0) {
        _submitExam();
      } else {
        setState(() => secondsRemaining--);
      }
    });
  }

  // ================= SUBMIT EXAM =================
  Future<void> _submitExam() async {
    _timer?.cancel();
    WakelockPlus.disable();

    int score = 0;

    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] ==
          questions[i]['correctAnswer']) {
        score++;
      }
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('results').add({
        'studentId': user.uid,
        'examId': examId,
        'score': score,
        'total': questions.length,
        'submittedAt': Timestamp.now(),
      });
    }

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/result',
      arguments: {
        'score': score,
        'total': questions.length,
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentIndex];
    final Map<String, dynamic> options =
        Map<String, dynamic>.from(question['options']);

    final minutes =
        (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds =
        (secondsRemaining % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: Text(examName),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⏱ TIMER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentIndex + 1} / ${questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text('$minutes:$seconds'),
                  backgroundColor: Colors.red.shade100,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ❓ QUESTION
            Text(
              question['questionText'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // ✅ OPTIONS
            ...options.entries.map((entry) {
              return RadioListTile<String>(
                value: entry.key,
                groupValue: selectedAnswers[currentIndex],
                title: Text('${entry.key}. ${entry.value}'),
                onChanged: (val) {
                  setState(() {
                    selectedAnswers[currentIndex] = val!;
                  });
                },
              );
            }),

            const Spacer(),

            // ⬅️ ➡️ CONTROLS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentIndex > 0)
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => currentIndex--),
                    child: const Text('Previous'),
                  ),

                if (currentIndex < questions.length - 1)
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => currentIndex++),
                    child: const Text('Next'),
                  ),

                if (currentIndex == questions.length - 1)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: _submitExam,
                    child: const Text('Submit'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

