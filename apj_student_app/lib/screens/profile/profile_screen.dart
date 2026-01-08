import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  File? imageFile;
  Map<String, dynamic>? student;

  @override
  void initState() {
    super.initState();
    _fetchStudent();
  }

  // ================= FETCH STUDENT =================
  Future<void> _fetchStudent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('students')
        .where('studentAuthUid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      student = snap.docs.first.data();
    }

    setState(() => isLoading = false);
  }

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  // ================= UPDATE PHOTO =================
  Future<void> _updatePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || imageFile == null) return;

    setState(() => isLoading = true);

    final ref =
    FirebaseStorage.instance.ref('students/profile_${user.uid}.jpg');

    await ref.putFile(imageFile!);
    final photoUrl = await ref.getDownloadURL();

    final snap = await FirebaseFirestore.instance
        .collection('students')
        .where('studentAuthUid', isEqualTo: user.uid)
        .limit(1)
        .get();

    await FirebaseFirestore.instance
        .collection('students')
        .doc(snap.docs.first.id)
        .update({'photoUrl': photoUrl});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo updated')),
    );

    _fetchStudent();
  }

  // ================= ACADEMIC YEAR =================
  String _academicYear() {
    if (student?['createdAt'] == null) return '';
    final date = DateTime.parse(student!['createdAt']);
    return '${date.year} - ${date.year + 1}';
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    ImageProvider? profileImage;

    if (imageFile != null) {
      profileImage = FileImage(imageFile!);
    } else if (student?['photoUrl'] != null &&
        student!['photoUrl'].toString().isNotEmpty) {
      profileImage = NetworkImage(student!['photoUrl']);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
            // ===== PHOTO =====
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: profileImage,
                child: profileImage == null
                    ? const Icon(Icons.camera_alt, size: 30)
                    : null,
              ),
            ),

            if (imageFile != null)
              TextButton.icon(
                onPressed: _updatePhoto,
                icon: const Icon(Icons.upload),
                label: const Text('Update Photo'),
              ),

            const SizedBox(height: 20),

            _card(
              child: Column(
                children: [
                  _info('Student Name', student!['name']),
                  _info('School Name', student!['school']),
                  _info('Registration Number',
                      student!['registrationNumber']),
                  _info('Gender', student!['gender']),
                  _info('Father Name', student!['fatherName']),
                  _info('Email', student!['studentEmail']),
                  _info('Class / Grade', student!['grade']),
                  _info('Phone', student!['phone']),
                  _info('Address', student!['address']),
                  _info('Academic Year', _academicYear()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _info(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '',
              softWrap: true,
              maxLines: null,
              overflow: TextOverflow.visible,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
