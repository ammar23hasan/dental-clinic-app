// lib/screens/privacy_security_screen.dart

import 'package:flutter/material.dart';
import '../constants.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  final Color primaryColor = kPrimaryColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy & Security',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // العودة لشاشة الملف الشخصي
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ********** 1. حالة الأمان **********
          _buildSecurityStatusCard(context),
          const SizedBox(height: 30),

          // ********** 2. إعدادات الأمان **********
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Security Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 20, thickness: 1),

          // تغيير كلمة المرور
          _buildSettingTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              // التنقل: يذهب إلى شاشة تغيير كلمة المرور
              Navigator.pushNamed(context, '/changePassword');
            },
          ),

          // المصادقة الثنائية (2FA)
          _buildSettingTile(
            icon: Icons.verified_user_outlined,
            title: 'Two-Factor Authentication (2FA)',
            onTap: () {
              // التنقل: يذهب إلى شاشة إعداد المصادقة الثنائية
              Navigator.pushNamed(context, '/twoFactorAuth');
            },
          ),

          // سياسة الخصوصية
          _buildSettingTile(
            icon: Icons.policy_outlined,
            title: 'View Privacy Policy',
            onTap: () {
              // التنقل: يذهب إلى شاشة عرض السياسة
              Navigator.pushNamed(context, '/privacyPolicy');
            },
          ),
        ],
      ),
    );
  }

  // دالة بناء بطاقة حالة الأمان
  Widget _buildSecurityStatusCard(BuildContext context) {
    return Card(
      color: primaryColor.withOpacity(0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Security Status: Good',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your account is protected. Last login: Today 10:30 AM.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة بناء خيار إعداد واحد
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}
