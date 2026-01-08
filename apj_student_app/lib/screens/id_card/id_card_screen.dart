import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IdCardScreen extends StatefulWidget {
  const IdCardScreen({super.key});

  @override
  State<IdCardScreen> createState() => _IdCardScreenState();
}

class _IdCardScreenState extends State<IdCardScreen> {
  bool isLoading = true;

  String studentName = '';
  String registrationNumber = '';
  String grade = '';
  String school = '';
  String fatherName = '';
  String phone = '';
  String photoUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchStudent();
  }

  Future<void> _fetchStudent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('students')
        .where('studentAuthUid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      final s = snap.docs.first.data();
      studentName = s['name'] ?? '';
      registrationNumber = s['registrationNumber'] ?? '';
      grade = s['grade'] ?? '';
      school = s['school'] ?? '';
      fatherName = s['fatherName'] ?? '---';
      phone = s['phone'] ?? '';
      photoUrl = s['photoUrl'] ?? '';
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student ID Card'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(child: _idCard()),
    );
  }

  // ================= ID CARD =================
  Widget _idCard() {
    return Container(
      width: 360,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ===== HEADER =====
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/school_logo.png',
                  height: 32,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'APJ Abdul Kalam Welfare Society',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Text(
                  'ID CARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // ===== BODY =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // PHOTO
                  Container(
                    width: 90,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: photoUrl.isNotEmpty
                          ? Image.network(photoUrl, fit: BoxFit.cover)
                          : const Icon(Icons.person, size: 40),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _row('Reg No', registrationNumber),
                        _row('Class', grade),
                        _row('Father', fatherName),
                        _row('Phone', phone),

                        // ✅ SCHOOL NOW HERE (PHONE KE NEECHAY)
                        _row('School', school),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== FOOTER =====
          Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Authorized Sign', style: TextStyle(fontSize: 10)),
                Text('Valid Till 2026', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 50, // 👈 thoda compact
            child: Text(
              '$title:',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              maxLines: 1,                 // ✅ SINGLE LINE
              overflow: TextOverflow.ellipsis, // ✅ NO WRAP
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
