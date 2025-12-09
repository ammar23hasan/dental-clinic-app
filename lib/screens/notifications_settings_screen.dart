// lib/screens/notifications_settings_screen.dart (الكود المحدّث بالكامل)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // لحفظ الإعدادات
import '../constants.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  // القيم الافتراضية
  bool _appointmentReminders = true;
  bool _offerPromotions = false;
  bool _systemAlerts = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // تحميل البيانات عند الفتح
  }

  // تحميل الإعدادات المحفوظة
  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appointmentReminders = prefs.getBool('reminders') ?? true;
      _offerPromotions = prefs.getBool('offers') ?? false;
      _systemAlerts = prefs.getBool('system') ?? true;
      _isLoading = false;
    });
  }

  // حفظ الإعدادات عند التغيير
  void _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setting saved successfully!', style: TextStyle(fontSize: 14)),
          duration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text('Control how you receive alerts from Dental Clinic.'),
                const SizedBox(height: 20),
                
                // 1. تذكيرات المواعيد
                _buildSwitchTile(
                  title: 'Appointment Reminders',
                  subtitle: 'Get alerts 24 hours before your visit.',
                  value: _appointmentReminders,
                  onChanged: (val) {
                    setState(() => _appointmentReminders = val);
                    _savePreference('reminders', val);
                  },
                ),

                // 2. العروض
                _buildSwitchTile(
                  title: 'Offers & Promotions',
                  subtitle: 'Receive discounts and special news.',
                  value: _offerPromotions,
                  onChanged: (val) {
                    setState(() => _offerPromotions = val);
                    _savePreference('offers', val);
                  },
                ),

                // 3. تنبيهات النظام
                _buildSwitchTile(
                  title: 'System Alerts',
                  subtitle: 'Critical updates and security notifications.',
                  value: _systemAlerts,
                  onChanged: (val) {
                    setState(() => _systemAlerts = val);
                    _savePreference('system', val);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required Function(bool) onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: SwitchListTile(
        activeThumbColor: kPrimaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
