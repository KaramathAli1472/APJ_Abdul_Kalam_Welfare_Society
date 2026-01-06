import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      debugPrint('🔹 Fetching notifications from Firestore...');

      // 🔹 Firestore query: Fetch all notifications, latest first
      final snap = await FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true) // latest first
          .get();

      debugPrint('📄 Total notifications fetched: ${snap.docs.length}');

      final notifs = snap.docs.map((doc) {
        final data = doc.data();

        // 🔹 Debug: print each document
        debugPrint('🔔 Notification doc: ${doc.id}, data: $data');

        return {
          'title': data['title'] ?? '',
          'message': data['message'] ?? '',
          'timestamp': data['timestamp'] ?? DateTime.now(),
          'status': data['status'] ?? '',
          'target': data['target'] ?? '',
          'deleted': data['deleted'] ?? false,
        };
      }).where((n) => n['deleted'] == false).toList(); // filter active only

      setState(() {
        notifications = notifs;
        isLoading = false;
      });

      debugPrint('✅ Notifications loaded into state: ${notifications.length}');
    } catch (e) {
      debugPrint('❌ Notification fetch error: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load notifications'),
          ),
        );
      }
    }
  }

  String _formatTimestamp(dynamic ts) {
    if (ts is Timestamp) {
      final dt = ts.toDate();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } else if (ts is DateTime) {
      return '${ts.day}/${ts.month}/${ts.year} ${ts.hour.toString().padLeft(2,'0')}:${ts.minute.toString().padLeft(2,'0')}';
    } else {
      return ts.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text('No notifications found'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    final ts = _formatTimestamp(n['timestamp']);

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n['title'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              n['message'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status: ${n['status']}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  ts,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

