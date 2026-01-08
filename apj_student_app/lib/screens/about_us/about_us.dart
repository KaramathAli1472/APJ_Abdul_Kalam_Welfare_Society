import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // ================= TITLE =================
                Text(
                  'A.P.J. Abdul Kalam Welfare Society',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '– Serving Education, Empowering Society',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 16),

                // ================= INTRO =================
                Text(
                  '👉  A.P.J. Abdul Kalam Welfare Society is a registered non-profit and social welfare organization based in Hyderabad, Telangana, working in the fields of education, student empowerment, and community welfare in honor of Bharat Ratna Dr. A. P. J. Abdul Kalam, the former President of India. The society is inspired by Dr. Kalam’s belief that education, compassion, and service to humanity are the foundations of a strong and developed nation. '
                      'The society works in the areas of education, student empowerment, '
                      'and community welfare in honor of Bharat Ratna Dr. A. P. J. Abdul '
                      'Kalam, the former President of India.\n\n'
                  '👉  Inspired by Dr. Kalam’s vision, the society believes that '
                      'education, compassion, and service to humanity are the key '
                      'pillars for building a strong and developed nation.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),

                SizedBox(height: 16),

                // ================= EDUCATION =================
                Text(
                  'Educational Support & Scholarships',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '👉  The society actively supports students by providing '
                      'educational encouragement and scholarship assistance. '
                      'Over the years, it has helped many deserving and '
                      'economically weaker students through scholarships, '
                      'financial aid, cash awards, and fee support.\n\n'
                  '👉  These efforts aim to reduce financial barriers and '
                      'motivate students to pursue higher education and '
                      'academic excellence.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),

                SizedBox(height: 16),

                // ================= EXAM =================
                Text(
                  'All India Mathematics Bright Student Award Test',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '👉  One of the key initiatives of the society is the '
                      'All India Mathematics Bright Student Award Test, a '
                      'national-level competitive examination conducted for '
                      'students of Classes 4 to 10 from CBSE, ICSE, and State '
                      'Boards.\n\n'
                  '👉  The examination is designed to strengthen mathematical '
                      'skills, logical thinking, and confidence among students. '
                      'Merit-based awards, certificates, and scholarships are '
                      'provided to recognize and encourage talented students.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),

                SizedBox(height: 16),

                // ================= OPERATIONS =================
                Text(
                  'Operations & Reach',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '👉  With its head office located at Santosh Nagar, Hyderabad, '
                      'the society carries out its educational and welfare '
                      'activities at district, state, and national levels.\n\n'
                  '👉  To ensure inclusiveness, programs and examinations are '
                      'offered in multiple languages including English, Telugu, '
                      'enabling students from diverse backgrounds '
                      'to participate.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),

                SizedBox(height: 16),

                // ================= SOCIAL WORK =================
                Text(
                  'Social Welfare Activities',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 8),
                BulletPoint(text: '👉 Distribution of blankets to poor and needy people'),
                BulletPoint(text: '👉 Providing food and meals to underprivileged families'),
                BulletPoint(text: '👉 Supporting school fees and educational expenses of needy children'),
                BulletPoint(text: '👉 Assisting poor families through welfare and relief programs'),
                BulletPoint(text: '👉 Conducting social service and community awareness activities'),

                SizedBox(height: 16),

                // ================= VALUES =================
                Text(
                  'Our Values',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '👉  The A.P.J. Abdul Kalam Welfare Society functions with '
                      'transparency, integrity, and a non-profit approach. '
                      'All activities are guided by the principles of equality, '
                      'service, and dedication to public welfare.\n\n'
                  '👉  By following the ideals of Dr. A. P. J. Abdul Kalam, '
                      'the society strives to empower students, uplift '
                      'communities, and contribute positively to the nation’s '
                      'progress.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),

                SizedBox(height: 24),

                // ================= CONTACT =================
                Divider(thickness: 1),
                SizedBox(height: 12),
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '👉  A.P.J. Abdul Kalam Welfare Society\n'
                  '👉  Office # 17-1-181/M/203, Sri Nagar Colony\n'
                  '👉  Santosh Nagar, Hyderabad\n 500059,Telangana, India'
                      '\n'
                  '👉  📧 apjedu2001@gmail.com',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= BULLET POINT =================
class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
