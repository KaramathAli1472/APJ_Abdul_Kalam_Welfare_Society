import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> syllabusList = [];
  String _selectedGrade = '7'; // Current selected grade

  // FIXED: Create unique list of grades
  final List<String> _availableGrades = ['7', '8', '9', '10'];

  @override
  void initState() {
    super.initState();
    _fetchSyllabus();
  }

  Future<void> _fetchSyllabus() async {
    try {
      setState(() => isLoading = true);

      debugPrint('📚 Fetching syllabus for Grade $_selectedGrade');

      // Get grade from SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      final savedGrade = prefs.getString('studentGrade');
      if (savedGrade != null && savedGrade.isNotEmpty) {
        // Ensure the saved grade is in our available grades list
        if (_availableGrades.contains(savedGrade)) {
          _selectedGrade = savedGrade;
        }
      }

      // Query with type casting
      Query query = FirebaseFirestore.instance
          .collection('syllabusUploads')
          .where('grade', isEqualTo: _selectedGrade);

      try {
        // Try to add orderBy
        query = query.orderBy('createdAt', descending: true);
      } catch (e) {
        debugPrint('⚠️ OrderBy not available, using simple query');
        // Continue without orderBy if index not created
      }

      final QuerySnapshot snap = await query.get();

      final List<Map<String, dynamic>> list = [];

      for (var doc in snap.docs) {
        // FIX: Cast data to Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final String? url = data['cloudinaryUrl']?.toString();
        if (url == null || url.trim().isEmpty) continue;

        // Format date
        String dateText = 'Recent';
        final createdAt = data['createdAt'];
        if (createdAt != null) {
          try {
            if (createdAt is Timestamp) {
              final date = createdAt.toDate();
              dateText = '${date.day}/${date.month}/${date.year}';
            } else if (createdAt is String) {
              dateText = createdAt;
            }
          } catch (e) {
            debugPrint('⚠️ Error formatting date: $e');
          }
        }

        list.add({
          'id': doc.id,
          'title': data['fileName']?.toString() ?? 'Untitled',
          'className': data['gradeLabel']?.toString() ?? 'Grade ${data['grade'] ?? _selectedGrade}',
          'courseName': data['courseName']?.toString() ?? 'General',
          'url': url,
          'type': data['fileType']?.toString() ?? 'image',
          'date': dateText,
          'fileSize': data['fileSize'] ?? 0,
          'uploadedBy': data['uploadedByName']?.toString() ?? 'Admin',
          'academicYear': data['academicYear']?.toString() ?? '2026',
        });
      }

      // Sort manually by date (descending)
      list.sort((a, b) {
        try {
          // Try to parse dates for sorting
          if (a['date'] == 'Recent') return -1;
          if (b['date'] == 'Recent') return 1;

          final dateA = a['date'].split('/');
          final dateB = b['date'].split('/');
          if (dateA.length == 3 && dateB.length == 3) {
            final dayA = int.tryParse(dateA[0]) ?? 1;
            final monthA = int.tryParse(dateA[1]) ?? 1;
            final yearA = int.tryParse(dateA[2]) ?? 2026;

            final dayB = int.tryParse(dateB[0]) ?? 1;
            final monthB = int.tryParse(dateB[1]) ?? 1;
            final yearB = int.tryParse(dateB[2]) ?? 2026;

            if (yearA != yearB) return yearB.compareTo(yearA);
            if (monthA != monthB) return monthB.compareTo(monthA);
            return dayB.compareTo(dayA);
          }
        } catch (e) {
          debugPrint('⚠️ Error sorting: $e');
        }
        return 0;
      });

      debugPrint('✅ Found ${list.length} syllabus items for Grade $_selectedGrade');

      if (!mounted) return;
      setState(() {
        syllabusList = list;
        isLoading = false;
      });

    } catch (e) {
      debugPrint('❌ ERROR fetching syllabus: $e');
      if (mounted) setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildSyllabusItem(Map<String, dynamic> item, int index) {
    final isPdf = item['type'] == 'pdf';

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
                // Icon Container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isPdf ? Colors.red.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPdf ? Colors.red.shade100 : Colors.blue.shade100,
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.image,
                    color: isPdf ? Colors.red : Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 10),

                // Content
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

                      // Subject
                      Row(
                        children: [
                          Icon(Icons.book, size: 14, color: Colors.grey[600]),
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

                      // Grade and Date
                      Row(
                        children: [
                          Icon(Icons.grade, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            item['className']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            item['date']!,
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

                // Arrow
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
          // Grade Selector Dropdown - FIXED VERSION
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGrade,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                dropdownColor: Colors.indigo,
                style: const TextStyle(color: Colors.white),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedGrade = newValue;
                    });
                    _fetchSyllabus();
                  }
                },
                // FIXED: Ensure unique items
                items: _availableGrades.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      'Grade $value',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
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
              Text(
                'No Syllabus for Grade $_selectedGrade',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for updates',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 10),
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
            // Header Card
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
                          'Grade $_selectedGrade • ${syllabusList.length} ${syllabusList.length == 1 ? 'Item' : 'Items'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select grade from dropdown to view different class syllabus',
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
                child: RefreshIndicator(
                  color: Colors.indigo,
                  onRefresh: _fetchSyllabus,
                  child: ListView.builder(
                    itemCount: syllabusList.length,
                    itemBuilder: (context, index) {
                      return _buildSyllabusItem(
                          syllabusList[index], index);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ViewerScreen Class
class ViewerScreen extends StatefulWidget {
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
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAndLoad();
  }

  void _checkAndLoad() {
    if (widget.url.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.indigo),
      )
          : widget.isPdf
          ? _buildPdfViewer()
          : _buildImageViewer(),
    );
  }

  Widget _buildPdfViewer() {
    return PDF().cachedFromUrl(
      widget.url,
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
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    return InteractiveViewer(
      panEnabled: true,
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: widget.url,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: Colors.indigo),
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
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}