import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? studentData;
  bool isLoading = true;
  String photoUrl = '';

  int totalResults = 0;
  int totalExams = 0;
  int totalNotifications = 0;
  int totalSyllabus = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // ================= FETCH DASHBOARD DATA =================
  Future<void> _fetchDashboardData() async {
    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 🔹 STUDENT
      final studentSnap = await FirebaseFirestore.instance
          .collection('students')
          .where('studentAuthUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (studentSnap.docs.isEmpty) return;

      final studentDoc = studentSnap.docs.first;
      final student = studentDoc.data();

      photoUrl = (student['photoUrl'] ??
              student['userPhoto'] ??
              student['profilePhoto'] ??
              '')
          .toString();

      // 🔹 RESULTS
      final resultsSnap = await FirebaseFirestore.instance
    .collection('results')
    .where('studentId', isEqualTo: user.uid)
    .where('approved', isEqualTo: true) // only approved
    .get();
totalResults = resultsSnap.docs.length;

      // 🔹 EXAMS (SAFE QUERY)
      final examsSnap =
          await FirebaseFirestore.instance.collection('exams').get();

      final activeExams = examsSnap.docs.where((doc) {
        final data = doc.data();
        return data['deleted'] != true; // 🔥 key fix
      }).toList();

      // 🔹 NOTIFICATIONS
      final notificationsSnap =
          await FirebaseFirestore.instance.collection('notifications').get();

      final activeNotifications = notificationsSnap.docs.where((doc) {
        return doc.data()['deleted'] != true;
      }).toList();

      // 🔹 SYLLABUS
      final syllabusSnap =
          await FirebaseFirestore.instance.collection('syllabusUploads').get();

      final activeSyllabus = syllabusSnap.docs.where((doc) {
        return doc.data()['deleted'] != true;
      }).toList();

      setState(() {
        studentData = student;
        totalResults = resultsSnap.docs.length;
        totalExams = activeExams.length;
        totalNotifications = activeNotifications.length;
        totalSyllabus = activeSyllabus.length;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Dashboard Error: $e');
      setState(() => isLoading = false);
    }
  }

  // ================= LOGOUT =================
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final method = prefs.getString('loginMethod');

    if (method == 'google') {
      await GoogleSignIn().signOut();
    }

    await FirebaseAuth.instance.signOut();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentData == null
              ? const Center(child: Text('No student data found'))
              : _dashboardBody(),
    );
  }

  // ================= DASHBOARD BODY =================
  Widget _dashboardBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _studentCard(),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _item('Syllabus', Icons.menu_book,
                  totalSyllabus.toString(), '/syllabus'),
              _item(
                  'Exams', Icons.assignment, totalExams.toString(), '/exam'),
              _item('Notifications', Icons.notifications,
                  totalNotifications.toString(), '/notice'),
              _item('Results', Icons.bar_chart,
                  totalResults.toString(), '/result'),
              _item('ID Card', Icons.badge, '', '/idcard'),
              _item('Profile', Icons.person, '', '/profile'),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STUDENT CARD =================
  Widget _studentCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.indigo.shade50,
            backgroundImage:
                photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty
                ? const Icon(Icons.person,
                    size: 30, color: Colors.indigo)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentData!['name'] ?? '',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reg No: ${studentData!['registrationNumber'] ?? ''}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  'Grade: ${studentData!['grade'] ?? ''}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= ITEM =================
  Widget _item(
      String title, IconData icon, String count, String route) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 6,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: Colors.indigo),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (count.isNotEmpty)
              Text(count,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
