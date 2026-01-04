import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? studentData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudent();

    // 🔥 DASHBOARD OPEN → SCREEN ALWAYS ON
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    // 🔕 DASHBOARD CLOSE → SCREEN NORMAL
    WakelockPlus.disable();
    super.dispose();
  }

  // ================= FETCH STUDENT =================
  Future<void> _fetchStudent() async {
    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('studentAuthUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        studentData = snapshot.docs.first.data();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Dashboard Error: $e');
      setState(() => isLoading = false);
    }
  }

  // ================= LOGOUT =================
  Future<void> _logout(BuildContext context) async {
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
            onPressed: () => _logout(context),
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
    final photo = (studentData!['profilePhoto'] ?? '').toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ===== STUDENT CARD =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      photo.isNotEmpty ? NetworkImage(photo) : null,
                  child: photo.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentData!['name'],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reg No: ${studentData!['registrationNumber']}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        'Grade: ${studentData!['grade']}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        studentData!['school'],
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: studentData!['status'] == 'active'
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    studentData!['status'].toString().toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: studentData!['status'] == 'active'
                          ? Colors.green[800]
                          : Colors.orange[800],
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ===== QUICK ACTIONS =====
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _item('Syllabus', Icons.menu_book, '/syllabus'),
              _item('Exam', Icons.assignment, '/exam'),
              _item('Result', Icons.bar_chart, '/result'),
              _item('ID Card', Icons.badge, '/idcard'),
              _item('Notice', Icons.campaign, '/notice'),
              _item('Profile', Icons.person, '/profile'),
            ],
          )
        ],
      ),
    );
  }

  Widget _item(String title, IconData icon, String route) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: Colors.indigo),
            const SizedBox(height: 10),
            Text(
              title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
