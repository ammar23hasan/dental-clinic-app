// lib/screens/notifications_settings_screen.dart (الكود المحدّث بالكامل)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- الاستيراد الجديد
import '../constants.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _appointmentReminders = true;
  bool _offerPromotions = false;
  bool _systemAlerts = true;
  bool _isLoading = true; // لمعرفة متى ينتهي تحميل الإعدادات

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences(); // <--- بدء تحميل الإعدادات عند بناء الشاشة
  }

  // ********** الدوال الوظيفية الحقيقية **********

  // دالة تحميل الإعدادات من الذاكرة المحلية
  void _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appointmentReminders = prefs.getBool('reminders') ?? true;
      _offerPromotions = prefs.getBool('offers') ?? false;
      _systemAlerts = prefs.getBool('system') ?? true;
      _isLoading = false;
    });
  }

  // دالة حفظ الإعدادات إلى الذاكرة المحلية
  void _saveNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders', _appointmentReminders);
    await prefs.setBool('offers', _offerPromotions);
    await prefs.setBool('system', _systemAlerts);

    // إظهار رسالة تأكيد بسيطة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Preferences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            ) // عرض شاشة تحميل
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Control how you receive alerts from Dental Clinic.',
                  style: TextStyle(color: Colors.grey),
                ),
                const Divider(height: 30),

                // إشعارات المواعيد
                _buildToggleTile(
                  title: 'Appointment Reminders',
                  subtitle: 'Get alerts 24 hours before your visit.',
                  value: _appointmentReminders,
                  onChanged: (bool newValue) {
                    setState(() {
                      _appointmentReminders = newValue;
                      _saveNotificationPreferences(); // <--- حفظ الحالة الجديدة
                    });
                  },
                ),

                // إشعارات العروض الترويجية
                _buildToggleTile(
                  title: 'Offers & Promotions',
                  subtitle:
                      'Receive discounts and special news from the clinic.',
                  value: _offerPromotions,
                  onChanged: (bool newValue) {
                    setState(() {
                      _offerPromotions = newValue;
                      _saveNotificationPreferences(); // <--- حفظ الحالة الجديدة
                    });
                  },
                ),

                // تنبيهات النظام
                _buildToggleTile(
                  title: 'System Alerts',
                  subtitle: 'Critical updates and security notifications.',
                  value: _systemAlerts,
                  onChanged: (bool newValue) {
                    setState(() {
                      _systemAlerts = newValue;
                      _saveNotificationPreferences(); // <--- حفظ الحالة الجديدة
                    });
                  },
                ),

                const Divider(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'To manage email or SMS notifications, please visit the web portal.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: kPrimaryColor,
    );
  }
}
