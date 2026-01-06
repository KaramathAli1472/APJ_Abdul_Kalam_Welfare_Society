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

  // Exam info
  String examName = '';
  int? marksObtained;
  int totalMarks = 100;
  double? percentage;
  String grade = '';
  String passFail = '';

  @override
  void initState() {
    super.initState();
    _fetchLatestApprovedResult();
  }

  // ================= FETCH LATEST APPROVED RESULT =================
  Future<void> _fetchLatestApprovedResult() async {
    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';
      debugPrint('🔹 Logged in user UID: ${user.uid}');

      // 🔹 Fetch student info
      final studentSnap = await FirebaseFirestore.instance
          .collection('students')
          .where('studentAuthUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (studentSnap.docs.isNotEmpty) {
        final sData = studentSnap.docs.first.data();
        studentName = sData['name'] ?? '';
        studentPhoto = sData['photoUrl'] ?? sData['profilePhoto'] ?? '';
        studentIdNumber = sData['registrationNumber'] ?? '';
        studentGrade = sData['grade'] ?? '';
        debugPrint('📌 Student Info: $studentName | $studentIdNumber | Grade: $studentGrade | Photo: $studentPhoto');
      }

      // 🔹 Fetch latest result
      final resultSnap = await FirebaseFirestore.instance
          .collection('results')
          .where('studentId', isEqualTo: user.uid)
          //.where('approved', isEqualTo: true)
          .orderBy('submittedAt', descending: true)
          .limit(1)
          .get();

      if (resultSnap.docs.isEmpty) {
        debugPrint('⚠️ No results found for this student');
        setState(() {
          marksObtained = null;
          percentage = null;
          grade = '';
          passFail = '';
          examName = '';
          isLoading = false;
        });
        return;
      }

      final rData = resultSnap.docs.first.data();
      debugPrint('📄 Result Data: $rData');

      // 🔹 Calculate marks from correct answers
      final correctAnswers = rData['correctAnswers'] ?? 0;
      final totalQuestions = rData['totalQuestions'] ?? 100;
      marksObtained = correctAnswers;

      // 🔹 Calculate percentage
      percentage = (marksObtained! / totalQuestions) * 100;
      totalMarks = totalQuestions;

      // 🔹 Calculate grade
      grade = _calculateGrade(percentage!);

      // 🔹 Determine Pass / Fail (threshold = 85%)
      passFail = percentage! >= 85 ? "Pass" : "Fail";

      debugPrint('✅ Marks: $marksObtained / $totalMarks | Percentage: ${percentage!.toStringAsFixed(2)}% | Grade: $grade | $passFail');

      // 🔹 Fetch exam name
      final examId = rData['examId'] ?? '';
      if (examId.isNotEmpty) {
        final examSnap = await FirebaseFirestore.instance
            .collection('exams')
            .doc(examId)
            .get();
        if (examSnap.exists) {
          final eData = examSnap.data();
          examName = eData?['examName'] ?? 'Exam';
          debugPrint('📌 Exam Name: $examName');
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('❌ ERROR fetching result: $e');
      setState(() => isLoading = false);
    }
  }

  // ================= GRADE CALCULATION =================
  String _calculateGrade(double percent) {
    if (percent >= 90) return 'A+';
    if (percent >= 80) return 'A';
    if (percent >= 70) return 'B';
    if (percent >= 60) return 'C';
    if (percent >= 50) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Result'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : marksObtained == null
              ? _noResultUI()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _resultCardUI(),
                  ),
                ),
    );
  }

  Widget _noResultUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info, color: Colors.orange, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Result Not Available',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your result is not approved yet or no exams completed.',
              textAlign: TextAlign.center,
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
    );
  }

  Widget _resultCardUI() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: studentPhoto.isNotEmpty
                      ? NetworkImage(studentPhoto)
                      : null,
                  child: studentPhoto.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(studentName,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('ID: $studentIdNumber',
                          style: const TextStyle(color: Colors.grey)),
                      Text('Grade: $studentGrade',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      Text('Exam: $examName',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'Marks: $marksObtained / $totalMarks  |  '
                        'Percentage: ${percentage!.toStringAsFixed(2)}%  |  '
                        'Grade: $grade  |  '
                        'Result: $passFail',
                        style: TextStyle(
                            fontSize: 16,
                            color: passFail == "Pass" ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/dashboard'),
              child: const Text('Back to Dashboard'),
            )
          ],
        ),
      ),
    );
  }
}

