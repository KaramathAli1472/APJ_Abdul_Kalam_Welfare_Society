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
          SnackBar(
            content: Text('Failed to load notifications'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  String _formatTimestamp(dynamic ts) {
    if (ts is Timestamp) {
      final dt = ts.toDate();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (ts is DateTime) {
      return '${ts.day}/${ts.month}/${ts.year} ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
    } else {
      return ts.toString();
    }
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    final ts = _formatTimestamp(notification['timestamp']);
    final status = notification['status'].toString().toLowerCase();
    
    // Color based on status
    Color statusColor = Colors.grey;
    Color bgColor = Colors.white;
    
    if (status.contains('important')) {
      statusColor = Colors.red;
      bgColor = Colors.red.shade50;
    } else if (status.contains('info')) {
      statusColor = Colors.blue;
      bgColor = Colors.blue.shade50;
    } else if (status.contains('success')) {
      statusColor = Colors.green;
      bgColor = Colors.green.shade50;
    } else if (status.contains('warning')) {
      statusColor = Colors.orange;
      bgColor = Colors.orange.shade50;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Status indicator
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getNotificationIcon(notification['title']),
                        color: Colors.indigo,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    
                    // Title and time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'],
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                ts.split(' ')[0], // Date only
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            ts.split(' ')[1], // Time only
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Message content
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade100,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    notification['message'],
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Footer with status and target
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        notification['status'].toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    
                    // Target info
                    if (notification['target'] != null && notification['target'].toString().isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4),
                          Text(
                            notification['target'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Notification number badge
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.indigo,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('exam') || lowerTitle.contains('test')) {
      return Icons.assignment;
    } else if (lowerTitle.contains('result') || lowerTitle.contains('marks')) {
      return Icons.bar_chart;
    } else if (lowerTitle.contains('holiday') || lowerTitle.contains('break')) {
      return Icons.beach_access;
    } else if (lowerTitle.contains('fee') || lowerTitle.contains('payment')) {
      return Icons.payment;
    } else if (lowerTitle.contains('meeting') || lowerTitle.contains('event')) {
      return Icons.event;
    } else if (lowerTitle.contains('syllabus') || lowerTitle.contains('course')) {
      return Icons.menu_book;
    } else {
      return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchNotifications,
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
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.indigo,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading Notifications...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No Notifications',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'You\'re all caught up!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: 25),
                        ElevatedButton.icon(
                          onPressed: _fetchNotifications,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.refresh, size: 20),
                          label: Text('Refresh'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Header Info Card
                      Container(
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.08),
                              blurRadius: 12,
                              offset: Offset(0, 4),
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
                              child: Icon(
                                Icons.notifications_active,
                                color: Colors.indigo,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${notifications.length} ${notifications.length == 1 ? 'Notification' : 'Notifications'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Latest notifications are shown first',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Notifications List
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationItem(
                                  notifications[index], index);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: notifications.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              onPressed: _fetchNotifications,
              child: Icon(Icons.refresh),
            )
          : null,
    );
  }
}