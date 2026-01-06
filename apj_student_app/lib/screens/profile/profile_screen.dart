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
  Map<String, dynamic>? studentData;
  bool isLoading = true;
  File? imageFile;

  final nameController = TextEditingController();
  final schoolController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // ================= FETCH PROFILE =================
  Future<void> _fetchProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snap = await FirebaseFirestore.instance
          .collection('students')
          .where('studentAuthUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return;

      studentData = snap.docs.first.data();
      nameController.text = studentData!['name'];
      schoolController.text = studentData!['school'];

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('❌ Profile Fetch Error: $e');
    }
  }

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  // ================= UPDATE PROFILE =================
  Future<void> _updateProfile() async {
    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? imageUrl = studentData!['profilePhoto'];

      // 🔹 Upload Image
      if (imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref('student_profiles/${user.uid}.jpg');

        await ref.putFile(imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      // 🔹 Update Firestore
      final snap = await FirebaseFirestore.instance
          .collection('students')
          .where('studentAuthUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      await FirebaseFirestore.instance
          .collection('students')
          .doc(snap.docs.first.id)
          .update({
        'name': nameController.text.trim(),
        'school': schoolController.text.trim(),
        'profilePhoto': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated Successfully')),
      );

      _fetchProfile();
    } catch (e) {
      debugPrint('❌ Update Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _body(),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 55,
              backgroundImage: imageFile != null
                  ? FileImage(imageFile!)
                  : (studentData!['profilePhoto'] != null &&
                          studentData!['profilePhoto'] != '')
                      ? NetworkImage(studentData!['profilePhoto'])
                      : null,
              child: studentData!['profilePhoto'] == null
                  ? const Icon(Icons.camera_alt, size: 30)
                  : null,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: schoolController,
            decoration: const InputDecoration(
              labelText: 'School',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Update Profile'),
              onPressed: _updateProfile,
            ),
          ),
        ],
      ),
    );
  }
}

