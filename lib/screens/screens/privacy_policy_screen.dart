// lib/screens/privacy_policy_screen.dart (الكود المطور)

import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Last Updated: October 2025',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('1. Data Collection'),
            const Text(
              'We collect data necessary for appointment booking and service provision, including your name, contact information, and medical history shared during visits. This data is stored securely on encrypted servers.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),

            _buildSectionTitle('2. Usage of Information'),
            const Text(
              'Your information is used solely to manage your dental care, communicate appointment updates, and improve clinic services. We do not sell your personal data to third parties.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),

            _buildSectionTitle('3. Security Measures'),
            const Text(
              'We employ industry-standard security protocols, including data encryption and two-factor authentication for staff, to protect your personal and medical records.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),

            Center(
              child: TextButton(
                onPressed: () {
                  // يمكن إضافة زر للعودة إذا لزم الأمر
                  Navigator.pop(context);
                },
                child: const Text('I Understand and Agree'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
