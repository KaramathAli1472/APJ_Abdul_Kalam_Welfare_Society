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

  Future<void> _loadExam() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('exams')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) throw Exception('No active exam found');

      final doc = snap.docs.first;
      final data = doc.data();

      setState(() {
        examId = doc.id;
        examName = data['examName'] ?? 'Exam';
        durationMinutes = (data['duration'] as num?)?.toInt() ?? 30;
        questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
        secondsRemaining = durationMinutes * 60;
        isLoading = false;
      });

      WakelockPlus.enable();
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active exam available')),
      );
      Navigator.pop(context);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining <= 0) {
        _submitExam();
      } else {
        setState(() => secondsRemaining--);
      }
    });
  }

  int _totalMarks() {
    // Total marks = sum of all question marks, default 100
    if (questions.isEmpty) return 100;
    int total = 0;
    for (var q in questions) {
      total += (q['marks'] as num?)?.toInt() ?? 1;
    }
    return total;
  }

  Future<void> _submitExam() async {
    _timer?.cancel();
    WakelockPlus.disable();

    int obtainedMarks = 0;

    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i]['correctAnswer']) {
        obtainedMarks += (questions[i]['marks'] as num?)?.toInt() ?? 1;
      }
    }

    final int totalMarks = _totalMarks();
    final double percentage = totalMarks == 0
        ? 0
        : double.parse(((obtainedMarks / totalMarks) * 100).toStringAsFixed(2));
    final bool isPass = percentage >= 85;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('results').add({
        'studentId': user.uid,
        'examId': examId,
        'examName': examName,
        'obtainedMarks': obtainedMarks,
        'totalMarks': totalMarks,
        'percentage': percentage,
        'result': isPass ? 'Pass' : 'Fail',
        'approved': false,
        'submittedAt': Timestamp.now(),
      });
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ResultPendingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(examName)),
        body: const Center(child: Text('No questions available')),
      );
    }

    final question = questions[currentIndex];
    final Map<String, dynamic> options =
        Map<String, dynamic>.from(question['options'] ?? {});

    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');

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
            Text(
              question['questionText'] ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentIndex > 0)
                  ElevatedButton(
                    onPressed: () => setState(() => currentIndex--),
                    child: const Text('Previous'),
                  ),
                if (currentIndex < questions.length - 1)
                  ElevatedButton(
                    onPressed: () => setState(() => currentIndex++),
                    child: const Text('Next'),
                  ),
                if (currentIndex == questions.length - 1)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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

class ResultPendingScreen extends StatelessWidget {
  const ResultPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result Status')),
      body: const Center(
        child: Text(
          'Your exam has been submitted.\nResult will be available after admin approval.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

