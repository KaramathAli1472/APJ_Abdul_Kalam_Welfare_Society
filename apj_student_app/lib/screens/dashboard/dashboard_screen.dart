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
          .get();

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
        title: const Text(
          'Student Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 24),
            onPressed: _logout,
            tooltip: 'Logout',
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.indigo,
                strokeWidth: 3,
              ),
            )
          : studentData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No student data found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchDashboardData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _dashboardBody(),
    );
  }

  // ================= DASHBOARD BODY =================
  Widget _dashboardBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _studentCard(),
          const SizedBox(height: 28),
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 0.9,
            children: [
              _item('Syllabus', Icons.menu_book, totalSyllabus.toString(),
                  '/syllabus', Colors.blue),
              _item('Exams', Icons.assignment, totalExams.toString(), '/exam',
                  Colors.green),
              _item('Notifications', Icons.notifications,
                  totalNotifications.toString(), '/notice', Colors.orange),
              _item('Results', Icons.bar_chart, totalResults.toString(),
                  '/result', Colors.purple),
              _item('ID Card', Icons.badge_outlined, '', '/idcard',
                  Colors.teal),
              _item('Profile', Icons.person_outline, '', '/profile',
                  Colors.pink),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.indigo.shade100, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.indigo.shade600,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap on any card to view details',
                    style: TextStyle(
                      color: Colors.indigo.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= STUDENT CARD =================
  Widget _studentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade600,
            Colors.indigo.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 36,
                      color: Colors.indigo.shade300,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentData!['name'] ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _infoRow(
                  Icons.badge,
                  'Reg No: ${studentData!['registrationNumber'] ?? 'N/A'}',
                ),
                const SizedBox(height: 4),
                _infoRow(
                  Icons.school,
                  'Grade: ${studentData!['grade'] ?? 'N/A'}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 16, color: Colors.white70),
      const SizedBox(width: 8),
      Expanded( // ✅ YEH LINE ADD KARO
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          maxLines: 2, // ✅ Optional: max lines add karo
          overflow: TextOverflow.ellipsis, // ✅ Overflow handle karo
        ),
      ),
    ],
  );
}

  // ================= ITEM =================
  Widget _item(
      String title, IconData icon, String count, String route, Color color) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            if (count.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}