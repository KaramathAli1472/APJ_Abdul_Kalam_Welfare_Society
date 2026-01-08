import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool isLoading = true;

  // Student info
  String studentName = '';
  String studentPhoto = '';
  String studentIdNumber = '';
  String studentGrade = '';

  // Result info
  String examName = '';
  int obtainedMarks = 0;
  int totalMarks = 0;
  double percentage = 0;
  String grade = '';
  String passFail = '';

  @override
  void initState() {
    super.initState();
    _fetchResult();
  }

  Future<void> _fetchResult() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ================= STUDENT =================
      final student = await FirebaseFirestore.instance
          .collection('students')
          .where('studentAuthUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (student.docs.isNotEmpty) {
        final s = student.docs.first.data();
        studentName = s['name'] ?? '';
        studentPhoto = s['photoUrl'] ?? '';
        studentIdNumber = s['registrationNumber'] ?? '';
        studentGrade = s['grade'] ?? '';
      }

      // ================= RESULT =================
      final result = await FirebaseFirestore.instance
          .collection('results')
          .where('studentId', isEqualTo: user.uid)
          .where('approved', isEqualTo: true)
          .orderBy('submittedAt', descending: true)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        final r = result.docs.first.data();
        examName = r['examName'] ?? '';
        obtainedMarks = (r['obtainedMarks'] ?? 0).toInt();
        totalMarks = (r['totalMarks'] ?? 0).toInt();
        percentage = (r['percentage'] ?? 0).toDouble();
        passFail = r['result'] ?? 'Fail';
        grade = _grade(percentage);
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _grade(double p) {
    if (p >= 90) return 'A+';
    if (p >= 80) return 'A';
    if (p >= 70) return 'B';
    if (p >= 60) return 'C';
    if (p >= 50) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    final bool isPass = passFail == 'Pass';
    final Color statusColor = isPass ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Result'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _studentCard(),                 // ✅ STUDENT
            _examNameOnlyCard(),            // ✅ EXAM NAME
            _infoCard(Icons.score, 'Total Marks', '$totalMarks'),
            _infoCard(Icons.check_circle, 'Obtained Marks', '$obtainedMarks'),
            _infoCard(Icons.percent, 'Percentage',
                '${percentage.toStringAsFixed(1)}%'),
            _infoCard(Icons.grade, 'Grade', grade),
            _performanceCard(statusColor),
            _statusCard(isPass, statusColor),
            _messageCard(),
          ],
        ),
      ),
    );
  }

  // ================= STUDENT CARD =================
  Widget _studentCard() {
    return _baseCard(
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage:
          studentPhoto.isNotEmpty ? NetworkImage(studentPhoto) : null,
          child: studentPhoto.isEmpty
              ? const Icon(Icons.person, size: 28)
              : null,
        ),
        title: Text(
          studentName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'ID: $studentIdNumber\nClass: $studentGrade',
          style: const TextStyle(height: 1.4),
        ),
      ),
    );
  }

  // ================= EXAM NAME ONLY =================
  Widget _examNameOnlyCard() {
    return _baseCard(
      color: Colors.indigo,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              examName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= INFO CARD =================
  Widget _infoCard(IconData icon, String title, String value) {
    return _baseCard(
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ================= PERFORMANCE =================
  Widget _performanceCard(Color color) {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            color: color,
          ),
        ],
      ),
    );
  }

  // ================= PASS / FAIL =================
  Widget _statusCard(bool isPass, Color color) {
    return _baseCard(
      child: Center(
        child: Text(
          isPass ? '✅ PASS' : '❌ FAIL', // ✅ FIXED
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  // ================= MESSAGE =================
  Widget _messageCard() {
    String msg;
    IconData icon;
    Color c;

    if (percentage >= 80) {
      msg = 'Excellent performance! Keep it up and aim higher.';
      icon = Icons.emoji_events_rounded;
      c = Colors.green;
    } else if (percentage >= 50) {
      msg = 'Good effort. Focus on weak areas to improve.';
      icon = Icons.trending_up_rounded;
      c = Colors.orange;
    } else {
      msg = 'Do not lose hope. Practice regularly and try again.';
      icon = Icons.school_rounded;
      c = Colors.red;
    }

    return _baseCard(
      color: c.withOpacity(0.08),
      child: Row(
        children: [
          Icon(icon, color: c, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: c,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BASE CARD =================
  Widget _baseCard({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
