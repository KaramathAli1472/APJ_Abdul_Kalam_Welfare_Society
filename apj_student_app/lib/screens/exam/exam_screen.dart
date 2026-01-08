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
        SnackBar(
          content: const Text('No active exam available'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
      return Scaffold(
        backgroundColor: Colors.indigo.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.indigo,
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                'Loading Exam...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.indigo,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please wait',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
  title: Text(
    examName,
    style: TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  backgroundColor: Colors.indigo,
  foregroundColor: Colors.white,
  centerTitle: true,
  elevation: 4,
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      _timer?.cancel();
      WakelockPlus.disable();
      Navigator.pop(context);
    },
  ),
),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 70,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 20),
              Text(
                'No questions available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Contact your administrator',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentIndex];
    final Map<String, dynamic> options =
        Map<String, dynamic>.from(question['options'] ?? {});

    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');

    return Scaffold(
  appBar: AppBar(
    title: Text(
      examName,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    backgroundColor: Colors.indigo,
    foregroundColor: Colors.white,
    automaticallyImplyLeading: false,
    centerTitle: true,
    elevation: 4,
    leading: IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        _timer?.cancel();
        WakelockPlus.disable();
        Navigator.pop(context);
      },
    ),
  ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Timer and Question Count
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${currentIndex + 1} of ${questions.length}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Marks: ${question['marks'] ?? '1'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: secondsRemaining < 300
                              ? [Colors.red.shade400, Colors.red.shade600]
                              : [Colors.indigo.shade400, Colors.indigo.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (secondsRemaining < 300
                                    ? Colors.red.shade200
                                    : Colors.indigo.shade200)
                                .withOpacity(0.5),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '$minutes:$seconds',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              // Question Card
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Q${currentIndex + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          question['questionText'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Options
                        Column(
                          children: options.entries.map((entry) {
                            final isSelected =
                                selectedAnswers[currentIndex] == entry.key;
                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    setState(() {
                                      selectedAnswers[currentIndex] = entry.key;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.indigo.shade50
                                          : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.indigo.shade300
                                            : Colors.grey.shade200,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.indigo
                                                : Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.indigo
                                                  : Colors.grey.shade400,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              entry.key,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            entry.value.toString(),
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: isSelected
                                                  ? Colors.indigo.shade800
                                                  : Colors.grey.shade800,
                                              fontWeight: isSelected
                                                  ? FontWeight.w500
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.indigo,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Navigation Buttons
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Button
                    if (currentIndex > 0)
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            onPressed: () => setState(() => currentIndex--),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.indigo,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.indigo, width: 1.5),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back_ios, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Previous',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Next/Submit Button
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: currentIndex > 0 ? 8 : 0),
                        child: ElevatedButton(
                          onPressed: currentIndex < questions.length - 1
                              ? () => setState(() => currentIndex++)
                              : _submitExam,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentIndex == questions.length - 1
                                ? Colors.green
                                : Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentIndex < questions.length - 1
                                    ? 'Next Question'
                                    : 'Submit Exam',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                currentIndex < questions.length - 1
                                    ? Icons.arrow_forward_ios
                                    : Icons.check_circle,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Indicator
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (currentIndex + 1) / questions.length,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.indigo,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '${((currentIndex + 1) / questions.length * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      appBar: AppBar(
        title: Text(
          'Result Status',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(24),
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Exam Submitted Successfully!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Your exam has been submitted successfully.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Result will be available after admin approval.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.home),
                  label: Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}