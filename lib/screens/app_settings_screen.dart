// lib/screens/app_settings_screen.dart (الكود المحدث ليعمل مع main.dart)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

// يجب أن تستقبل دالة callback في المُنشئ (Constructor)
class AppSettingsScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChange;

  const AppSettingsScreen({
    super.key,
    required this.onThemeChange, // <--- المتغير الجديد
  });

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  String _selectedLanguage = 'English';
  bool _darkModeEnabled = false;
  bool _isLoading = true;

  final List<String> _supportedLanguages = ['English', 'Arabic', 'Spanish'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ********** الدوال الوظيفية الحقيقية **********

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _isLoading = false;
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkModeEnabled);
    await prefs.setString('language', _selectedLanguage);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('App settings saved!')));
  }

  // ********** تصميم الواجهة **********

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // ********** قسم المظهر (Appearance) **********
                const Text(
                  'Appearance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),

                // 1. الوضع الداكن (Dark Mode)
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark themes.'),
                  value: _darkModeEnabled,
                  onChanged: (bool newValue) {
                    setState(() {
                      _darkModeEnabled = newValue;
                      _saveSettings();
                      // **الاستدعاء الحقيقي:** إخبار MyApp بتغيير الثيم
                      widget.onThemeChange(newValue);
                    });
                  },
                  activeColor: kPrimaryColor,
                ),

                // 2. إعداد اللغة (Language)
                ListTile(
                  title: const Text('Language'),
                  subtitle: Text('Current: $_selectedLanguage'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onTap: () => _showLanguagePicker(context),
                ),

                const SizedBox(height: 30),
                // ... (بقية الأكواد)
              ],
            ),
    );
  }

  // ... (بقية الدوال المساعدة)
  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: _supportedLanguages.map((lang) {
            return ListTile(
              title: Text(lang),
              trailing: _selectedLanguage == lang
                  ? Icon(Icons.check, color: kPrimaryColor)
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = lang;
                  _saveSettings();
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildInfoTile({required String title, required String subtitle}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Text(subtitle, style: const TextStyle(color: Colors.grey)),
    );
  }
}
