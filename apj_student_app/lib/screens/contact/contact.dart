import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../about_us/about_us.dart'; // ✅ CORRECT PATH

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  // ================= STATIC CONST DATA =================
  static const String email = 'apjedu2001@gmail.com';
  static const String whatsappNumber = '918500212306'; // without +
  static const String privacyPolicyUrl =
      'https://karamathali1472.github.io/apj-privacy-policy/';

  // ================= EMAIL =================
  Future<void> _launchEmail(BuildContext context) async {
    print('📧 Email tile clicked');

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Inquiry from App',
      },
    );

    print('📧 Email URI: $emailUri');

    try {
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      print('📧 System email compose opened');
    } catch (e) {
      print('❌ Email launch failed: $e');
      _showSnackBar(
        context,
        'No email app found. Please install an email app.',
      );
    }
  }

  // ================= WHATSAPP =================
  Future<void> _launchWhatsApp(BuildContext context) async {
    print('💬 WhatsApp tile clicked');

    final Uri whatsappUri =
    Uri.parse('https://wa.me/$whatsappNumber');

    print('💬 WhatsApp URI: $whatsappUri');

    final bool canLaunch = await canLaunchUrl(whatsappUri);
    print('💬 canLaunchUrl(whatsapp): $canLaunch');

    if (canLaunch) {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
      print('💬 WhatsApp opened');
    } else {
      print('❌ WhatsApp not available');
      _showSnackBar(context, 'WhatsApp not available.');
    }
  }

  // ================= URL =================
  Future<void> _launchUrl(BuildContext context, String url) async {
    print('🌐 URL tile clicked');
    print('🌐 URL: $url');

    final Uri uri = Uri.parse(url);

    final bool canLaunch = await canLaunchUrl(uri);
    print('🌐 canLaunchUrl(url): $canLaunch');

    if (canLaunch) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      print('🌐 URL opened');
    } else {
      print('❌ Could not open URL');
      _showSnackBar(context, 'Could not open link.');
    }
  }

  // ================= SNACKBAR =================
  void _showSnackBar(BuildContext context, String message) {
    print('🔔 Snackbar shown: $message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ================= TILE =================
  Widget _optionTile(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          print('👉 Tile tapped: $title');
          onTap();
        },
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    print('🧱 ContactUsScreen build called');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _optionTile(
            context,
            'Email Us',
            Icons.email,
                () => _launchEmail(context),
          ),
          _optionTile(
            context,
            'Chat on WhatsApp',
            Icons.chat,
                () => _launchWhatsApp(context),
          ),
          _optionTile(
            context,
            'Privacy Policy',
            Icons.privacy_tip,
                () => _launchUrl(context, privacyPolicyUrl),
          ),
          _optionTile(
            context,
            'About Us',
            Icons.info_outline,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutUsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
