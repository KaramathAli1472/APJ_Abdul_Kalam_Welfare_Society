import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _dashboardItem(
            context,
            icon: Icons.assignment,
            title: 'Start Exam',
            route: '/exam',
          ),
          _dashboardItem(
            context,
            icon: Icons.bar_chart,
            title: 'Result',
            route: '/result',
          ),
          _dashboardItem(
            context,
            icon: Icons.badge,
            title: 'ID Card',
            route: '/idcard',
          ),
          _dashboardItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _dashboardItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ??
          () {
            Navigator.pushNamed(context, route!);
          },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
