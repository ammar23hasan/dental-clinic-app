import 'package:flutter/material.dart';
import '../constants.dart'; // مسار ملف الثوابت

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final Color primaryColor = kPrimaryColor; // اللون الأزرق الأساسي

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/editProfile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),

              // ********** 1. قسم المعلومات العامة (البطاقة الزرقاء) **********
              _buildUserInfoCard(),
              const SizedBox(height: 20),

              // ********** 2. قسم المعلومات الشخصية المفصلة **********
              _buildPersonalInformationCard(),
              const SizedBox(height: 30),

              // ********** 3. قسم الإعدادات والخيارات **********
              _buildSettingsOption(
                context,
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Manage your notification preferences',
              ),
              _buildSettingsOption(
                context,
                icon: Icons.security_outlined,
                title: 'Privacy & Security',
                subtitle: 'Update your privacy settings',
              ),
              _buildSettingsOption(
                context,
                icon: Icons.settings_outlined,
                title: 'App Settings',
                subtitle: 'Customize your app experience',
              ),
              _buildSettingsOption(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help or contact support',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // الدوال المساعدة (Helper Widgets)
  // -------------------------------------------------------------------

  // بناء بطاقة معلومات المستخدم العامة (الزرقاء)
  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.person_outline, size: 40, color: Colors.white),
          SizedBox(height: 10),
          Text(
            'Ammar Hasan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'ammarhasan@gmail.com',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          Text(
            '+1 (555) 123-4567',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // بناء بطاقة المعلومات الشخصية المفصلة
  Widget _buildPersonalInformationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Full Name',
            value: 'Ammar Hasan',
          ),
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'ammarhasan@gmail.com',
          ),
          _buildInfoRow(
            icon: Icons.call_outlined,
            label: 'Phone',
            value: '+1 (555) 123-4567',
          ),
        ],
      ),
    );
  }

  // بناء صف لكل معلومة شخصية
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // بناء خيارات الإعدادات (البطاقات التي تملأ العرض)
  // ********** الدالة المحدثة للإعدادات (مع منطق التنقل) **********
  Widget _buildSettingsOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    String routeName;
    if (title == 'Notifications') {
      routeName = '/notifications';
    } else if (title == 'Privacy & Security') {
      routeName = '/privacySecurity';
    } else if (title == 'App Settings') {
      routeName = '/appSettings';
    } else if (title == 'Help & Support') {
      routeName = '/helpSupport';
    } else {
      routeName = '';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: () {
          if (routeName.isNotEmpty) {
            Navigator.pushNamed(context, routeName);
          } else {
            print('Route not defined for $title');
          }
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryColor),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
