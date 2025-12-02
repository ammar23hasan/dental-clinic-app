// lib/screens/help_support_screen.dart (الكود المطور)

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // البيانات الفعلية للتواصل
  static const String _phoneNumber = '+15559876543';
  static const String _emailAddress = 'support@dentalclinic.com';

  // دوال الإجراءات الخارجية
  Future<void> _launchPhone(BuildContext context, String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        final bool launched = await launchUrl(phoneUri,
            mode: LaunchMode.externalApplication);
        if (!launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch phone dialer.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer.')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while trying to call.')),
      );
    }
  }

  Future<void> _launchEmail(BuildContext context, String emailAddress) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: emailAddress);
    try {
      if (await canLaunchUrl(emailUri)) {
        final bool launched = await launchUrl(emailUri,
            mode: LaunchMode.externalApplication);
        if (!launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch email application.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email application.')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while trying to open email.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ********** 1. قسم المساعدة السريعة (Quick Help) - بتنسيق الشبكة **********
            const Text(
              'Quick Help',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // استخدم GridView بدون ارتفاع ثابت واجعلها shrink-wrapped
            GridView.count(
              shrinkWrap: true, // يسمح للـ GridView أن يأخذ ارتفاع المحتوى داخل SingleChildScrollView
              crossAxisCount: 2,
              childAspectRatio: 1.2, // تقليل النسبة لزيادة ارتفاع البطاقات عمودياً
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(), // منع التمرير المتداخل
              children: [
                _buildQuickHelpCard(
                  context,
                  title: 'FAQ',
                  subtitle: 'Common Questions',
                  icon: Icons.live_help_outlined,
                  onTap: () => Navigator.pushNamed(context, '/faqScreen'),
                ),
                _buildQuickHelpCard(
                  context,
                  title: 'Report',
                  subtitle: 'Submit a bug or issue',
                  icon: Icons.bug_report_outlined,
                  onTap: () =>
                      Navigator.pushNamed(context, '/reportProblemScreen'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ********** 2. قسم التواصل معنا (Contact Us) - ببطاقات مفصلة **********
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _buildContactCard(
              context: context,
              icon: Icons.phone_outlined,
              title: 'Call Support Hotline',
              subtitle: '+1 (555) 987-6543',
              onTap: () => _launchPhone(context, _phoneNumber),
              isCall: true,
            ),
            const SizedBox(height: 15),

            _buildContactCard(
              context: context,
              icon: Icons.email_outlined,
              title: 'Email Us',
              subtitle: _emailAddress,
              onTap: () => _launchEmail(context, _emailAddress),
              isCall: false,
            ),
          ],
        ),
      ),
    );
  }

  // ********** الدوال المساعدة (Helper Widgets) **********

  // دالة لبناء بطاقات المساعدة السريعة (Grid View Items)
  Widget _buildQuickHelpCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // <--- تأكد من هذا الترتيب
            children: [
              // الأيقونة (في الأعلى)
              Icon(icon, size: 30, color: kPrimaryColor),

              // النصوص (في الأسفل)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow
                        .ellipsis, // <--- إضافة لمنع الفيضان في العرض
                    maxLines: 1,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لبناء بطاقات التواصل (List Tiles)
  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isCall,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Theme.of(context).cardColor,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kPrimaryColor, semanticLabel: title),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: Icon(
          isCall ? Icons.call_outlined : Icons.mail_outline,
          color: kPrimaryColor,
        ),
      ),
    );
  }
}
