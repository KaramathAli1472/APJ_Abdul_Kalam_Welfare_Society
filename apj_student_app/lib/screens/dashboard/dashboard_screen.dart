import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ✅ FIXED: Complete Logout Function
  Future<void> _logout(BuildContext context) async {
    try {
      print('🚪 Starting logout process...');
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? currentUser = auth.currentUser;
      print('👤 Current User: ${currentUser?.email}');
      print('🔑 Providers: ${currentUser?.providerData.map((p) => p.providerId)}');

      final prefs = await SharedPreferences.getInstance();
      final savedMethod = prefs.getString('loginMethod');
      print('💾 Saved loginMethod: $savedMethod');

      // Decide if Google sign-out is required (either provider or saved pref indicates google)
      final usesGoogle = (currentUser?.providerData.any((p) => p.providerId == 'google.com') ?? false)
          || (savedMethod == 'google');

      if (usesGoogle) {
        final googleSignIn = GoogleSignIn();
        try {
          // Attempt sign out & disconnect to revoke tokens
          await googleSignIn.signOut();
          await googleSignIn.disconnect();
          print('✅ Google signOut & disconnect successful');
        } catch (e) {
          print('⚠️ Google signOut/disconnect error: $e');
        }
      } else {
        print('ℹ️ Google sign-in not detected, skipping Google sign-out.');
      }

      // Sign out from FirebaseAuth
      try {
        await auth.signOut();
        print('✅ Firebase Auth signed out');
      } catch (e) {
        print('⚠️ Firebase signOut error: $e');
      }

      // Clear SharedPreferences after sign-outs
      try {
        await prefs.clear();
        print('✅ SharedPreferences cleared');
      } catch (e) {
        print('⚠️ Error clearing SharedPreferences: $e');
      }

      // Feedback and navigation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
      );

      // Ensure navigation stack cleared
      await Future.delayed(const Duration(milliseconds: 200));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print('❌ Logout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}'), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
      );
      try {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } catch (e2) {
        print('❌ Navigation error: $e2');
      }
    }
  }

  // ✅ Enhanced Logout Confirmation Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.logout, color: Colors.orange),
              SizedBox(width: 10),
              Text(
                'Confirm Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber, size: 50, color: Colors.orange),
            SizedBox(height: 10),
            Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              'You will need to login again to access your account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, size: 18),
                SizedBox(width: 8),
                Text('Logout'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    const Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, size: 20),
                    const SizedBox(width: 8),
                    const Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ User Welcome Section
            FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final prefs = snapshot.data!;
                  final userName = prefs.getString('fullName') ?? 'Student';
                  final userEmail = prefs.getString('userEmail') ?? '';
                  final regNumber = prefs.getString('registrationNumber') ?? 'Not Assigned';
                  final loginMethod = prefs.getString('loginMethod') ?? 'email';
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade100,
                          child: FutureBuilder<String>(
                            future: () async {
                              final photo = prefs.getString('userPhoto');
                              if (photo != null && photo.isNotEmpty && photo.contains('http')) {
                                return photo;
                              }
                              return '';
                            }(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                return ClipOval(
                                  child: Image.network(
                                    snapshot.data!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Colors.blue.shade700,
                                      );
                                    },
                                  ),
                                );
                              }
                              return Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.blue.shade700,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, $userName!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    loginMethod == 'google' 
                                        ? Icons.g_mobiledata 
                                        : Icons.email,
                                    size: 14,
                                    color: loginMethod == 'google' 
                                        ? Colors.red.shade600 
                                        : Colors.green.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      userEmail.isNotEmpty ? userEmail : 'No email provided',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Text(
                                  'ID: $regNumber',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Login: ${loginMethod == 'google' ? 'Google Account' : 'Email/Password'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ...removed redundant logout button (use PopupMenu logout only)...
                      ],
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // ✅ Dashboard Title
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an option to continue',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 25),
            
            // ✅ Dashboard Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _dashboardItem(
                    context,
                    icon: Icons.assignment_outlined,
                    title: 'Start Exam',
                    description: 'Take your exam',
                    color: Colors.green,
                    route: '/exam',
                  ),
                  _dashboardItem(
                    context,
                    icon: Icons.bar_chart_outlined,
                    title: 'Result',
                    description: 'View your results',
                    color: Colors.orange,
                    route: '/result',
                  ),
                  _dashboardItem(
                    context,
                    icon: Icons.badge_outlined,
                    title: 'ID Card',
                    description: 'Download ID Card',
                    color: Colors.purple,
                    route: '/idcard',
                  ),
                  // ...removed dashboard logout tile (use PopupMenu logout only)...
                ],
              ),
            ),
          ],
        ),
      ),
      
      // ✅ Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.copyright, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 5),
            Text(
              '${DateTime.now().year} A.P.J Abdul Kalam Welfare Society',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Dashboard Item Widget
  Widget _dashboardItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    String? route,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap ??
            (() {
              if (route != null) {
                Navigator.pushNamed(context, route);
              }
            }),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}