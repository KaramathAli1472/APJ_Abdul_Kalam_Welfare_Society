import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
          'date': data['createdAt']?.toString() ?? '',
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

  Widget _buildSyllabusItem(Map<String, String> item, int index) {
    final isPdf = item['type'] == 'pdf';
    final dateText = item['date']!.isNotEmpty
        ? _formatDate(item['date']!)
        : 'Date not available';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left Icon Container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isPdf
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPdf
                          ? Colors.red.shade100
                          : Colors.blue.shade100,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.image,
                    color: isPdf ? Colors.red : Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Middle Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.class_,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['className']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.book,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['courseName']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right Arrow
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.contains('Timestamp')) {
        return 'Recent';
      }
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Syllabus',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  ),
  centerTitle: true,
  backgroundColor: Colors.indigo,
  foregroundColor: Colors.white,
  elevation: 4,
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: _fetchSyllabus,
      tooltip: 'Refresh',
    ),
  ],
),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade50,
              Colors.white,
            ],
          ),
        ),
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.indigo,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Syllabus...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : syllabusList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Syllabus Available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for updates',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _fetchSyllabus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Header Info Card
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.library_books,
                                color: Colors.indigo,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${syllabusList.length} Syllabus ${syllabusList.length == 1 ? 'Item' : 'Items'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap any item to view details',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Syllabus List
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            itemCount: syllabusList.length,
                            itemBuilder: (context, index) {
                              return _buildSyllabusItem(
                                  syllabusList[index], index);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class ViewerScreen extends StatelessWidget {
  final String url;
  final String title;
  final bool isPdf;
  const ViewerScreen({
    super.key,
    required this.url,
    required this.title,
    required this.isPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading $title'),
                  backgroundColor: Colors.indigo,
                ),
              );
            },
            tooltip: 'Download',
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: isPdf
            ? PDF().cachedFromUrl(
                url,
                placeholder: (progress) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress != null ? progress / 100 : null,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading PDF... ${progress?.toStringAsFixed(0) ?? '0'}%',
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                errorWidget: (error) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load PDF',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Retry loading
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : _buildSimpleImageViewer(context), // 🔥 context pass karo
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  // 🔥 SIMPLE & INSTANT IMAGE VIEWER
  Widget _buildSimpleImageViewer(BuildContext context) {
    return InteractiveViewer(
      panEnabled: true,
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            // 🔥 INSTANT SHOW - Return image immediately
            if (loadingProgress == null) return child;
            
            // Agar load ho raha hai to bhi image show karo
            return Opacity(
              opacity: 0.8,
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.broken_image_outlined,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load image',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Alternative: CachedNetworkImage version
  Widget _buildCachedImageViewer(BuildContext context) {
    return InteractiveViewer(
      panEnabled: true,
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.image,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.broken_image_outlined,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load image',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
        ),
      ),
    );
  }
}