// lib/screens/two_factor_auth_screen.dart (الكود المطور)

import 'package:flutter/material.dart';
import '../constants.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _is2faEnabled = false;

  void _toggle2fa(bool newValue) {
    setState(() {
      _is2faEnabled = newValue;
    });

    if (newValue) {
      // TODO: هنا يتم بدء عملية الإعداد (إرسال رمز SMS، إلخ)
      print('2FA setup initiated!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Starting 2FA setup. Check your phone for a code.'),
        ),
      );
    } else {
      // TODO: هنا يتم إرسال طلب لتعطيل 2FA
      print('2FA disabled!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Two-Factor Authentication',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Card(
            color: kPrimaryColor.withOpacity(0.1),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enhance Your Security',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '2FA adds an extra layer of security by requiring a verification code sent to your phone number.',
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          SwitchListTile(
            title: const Text(
              'Enable Two-Factor Authentication',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _is2faEnabled
                  ? 'Currently Active'
                  : 'Disabled. Click to start setup.',
            ),
            value: _is2faEnabled,
            onChanged: _toggle2fa,
            activeColor: kPrimaryColor,
          ),

          if (_is2faEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recovery Codes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Save these codes to regain access if you lose your phone.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download, color: Colors.green),
                    title: const Text('Download Recovery Codes'),
                    onTap: () {
                      // TODO: إضافة منطق لتحميل الأكواد
                      print('Download codes tapped');
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
