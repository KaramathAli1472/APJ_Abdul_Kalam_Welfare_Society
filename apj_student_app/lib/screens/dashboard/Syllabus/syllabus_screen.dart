import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  String? pdfUrl;
  bool loading = true;
  final PdfViewerController _pdfController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    _loadSyllabus();
  }

  // ================= LOAD SYLLABUS PDF =================
  Future<void> _loadSyllabus() async {
    try {
      setState(() => loading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        loading = false;
        return;
      }

      // 🔹 Fetch student
      final studentSnap = await FirebaseFirestore.instance
          .collection('students')
          .where('studentAuthUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (studentSnap.docs.isEmpty) {
        setState(() => loading = false);
        return;
      }

      final grade = studentSnap.docs.first['grade'].toString();

      // 🔹 Fetch syllabus PDF by grade
      final syllabusSnap = await FirebaseFirestore.instance
          .collection('syllabus')
          .doc('grade_$grade')
          .get();

      if (!syllabusSnap.exists || syllabusSnap['pdfUrl'] == null) {
        setState(() {
          pdfUrl = null;
          loading = false;
        });
        return;
      }

      setState(() {
        pdfUrl = syllabusSnap['pdfUrl'];
        loading = false;
      });
    } catch (e) {
      debugPrint('❌ Syllabus error: $e');
      setState(() => loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syllabus PDF'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _loadSyllabus,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : pdfUrl == null
              ? _emptyView()
              : _pdfView(),
    );
  }

  // ================= PDF VIEW =================
  Widget _pdfView() {
    return SfPdfViewer.network(
      pdfUrl!,
      controller: _pdfController,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      enableTextSelection: true,
      onDocumentLoadFailed: (details) {
        debugPrint('❌ PDF Load Failed: ${details.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load PDF')),
        );
      },
    );
  }

  // ================= EMPTY STATE =================
  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Syllabus not available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please contact school admin',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadSyllabus,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
