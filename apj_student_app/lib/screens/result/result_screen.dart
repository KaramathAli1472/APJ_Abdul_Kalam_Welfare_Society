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
  int? score;
  int? total;
  String examName = '';

  @override
  void initState() {
    super.initState();
    _fetchLatestResult();
  }

  Future<void> _fetchLatestResult() async {
    try {
      setState(() => isLoading = true);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      final snap = await FirebaseFirestore.instance
          .collection('results')
          .where('studentId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        throw 'No results found';
      }

      final data = snap.docs.first.data();
      setState(() {
        score = data['score'] ?? 0;
        total = data['total'] ?? 100;
        examName = data['examName'] ?? 'Exam';
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ ERROR fetching result: $e');
      setState(() {
        score = 0;
        total = 100;
        examName = 'Exam';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exam Result',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events,
                          color: Colors.green, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Congratulations!',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('You have successfully completed "$examName"'),
                      const SizedBox(height: 16),
                      Text(
                        'Score: $score / $total',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, '/dashboard');
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
