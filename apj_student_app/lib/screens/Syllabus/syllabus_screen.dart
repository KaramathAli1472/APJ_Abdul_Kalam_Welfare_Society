import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  bool isLoading = true;
  List<Map<String, String>> syllabusList = [];

  @override
  void initState() {
    super.initState();
    _fetchSyllabus();
  }

  Future<void> _fetchSyllabus() async {
    try {
      setState(() => isLoading = true);

      final snap = await FirebaseFirestore.instance
          .collection('syllabusUploads')
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, String>> list = [];

      for (var doc in snap.docs) {
        final data = doc.data();
        String? url = data['cloudinaryUrl']?.toString();
        if (url == null || url.trim().isEmpty) continue;

        list.add({
          'title': data['fileName']?.toString() ?? 'Untitled',
          'className': data['classLabel']?.toString() ??
              data['className']?.toString() ??
              'Unknown Class',
          'courseName': data['courseName']?.toString() ?? 'General',
          'url': url,
          'type': data['fileType']?.toString() ?? 'image', // image or pdf
        });
      }

      if (!mounted) return;
      setState(() {
        syllabusList = list;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ ERROR fetching syllabus: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Syllabus',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : syllabusList.isEmpty
              ? const Center(child: Text('No syllabus available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: syllabusList.length,
                  itemBuilder: (_, i) {
                    final item = syllabusList[i];
                    final isPdf = item['type'] == 'pdf';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          isPdf ? Icons.picture_as_pdf : Icons.image,
                          color: isPdf ? Colors.red : Colors.green,
                          size: 40,
                        ),
                        title: Text(item['title']!),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['courseName']!),
                            Text(item['className']!),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white),
                        onTap: () {
                          // 🔹 Directly open PDF or Image page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewerScreen(
                                url: item['url']!,
                                title: item['title']!,
                                isPdf: isPdf,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class ViewerScreen extends StatelessWidget {
  final String url;
  final String title;
  final bool isPdf;
  const ViewerScreen(
      {super.key, required this.url, required this.title, required this.isPdf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: isPdf
          ? PDF().cachedFromUrl(
              url,
              placeholder: (progress) =>
                  Center(child: Text('Loading... $progress %')),
              errorWidget: (error) =>
                  Center(child: Text('Failed to load PDF\n$error')),
            )
          : Center(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                ),
              ),
            ),
    );
  }
}
