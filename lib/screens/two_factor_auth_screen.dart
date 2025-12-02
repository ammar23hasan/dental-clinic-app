// lib/screens/two_factor_auth_screen.dart (الكود المطور)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // لحفظ الحالة في قاعدة البيانات
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _is2FAEnabled = false;
  bool _isLoading = true;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _load2FAStatus();
  }

  // جلب الحالة من Firestore
  void _load2FAStatus() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _is2FAEnabled = doc.data()?['is2FAEnabled'] ?? false;
            _isLoading = false;
          });
        } else {
          if (mounted) {
            setState(() {
              _is2FAEnabled = false;
              _isLoading = false;
            });
          }
        }
      } on FirebaseException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load 2FA status: ${e.message}'), backgroundColor: Colors.red),
          );
          setState(() => _isLoading = false);
        }
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // تحديث الحالة في Firestore
  void _toggle2FA(bool newValue) async {
    setState(() => _isLoading = true);

    if (user != null) {
      try {
        // تحديث الحقل في مستند المستخدم
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'is2FAEnabled': newValue,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() {
            _is2FAEnabled = newValue;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(newValue ? '2FA Enabled Successfully' : '2FA Disabled'),
              backgroundColor: newValue ? Colors.green : Colors.grey,
            ),
          );
        }
      } on FirebaseException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update 2FA: ${e.message}'), backgroundColor: Colors.red),
          );
          setState(() => _isLoading = false);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No logged in user.'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Two-Factor Authentication', style: TextStyle(fontWeight: FontWeight.bold))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      '2FA adds an extra layer of security by requiring a verification code sent to your phone number.',
                      style: TextStyle(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SwitchListTile(
                    title: const Text('Enable Two-Factor Authentication', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(_is2FAEnabled ? 'Currently Active' : 'Currently Inactive'),
                    value: _is2FAEnabled,
                    onChanged: _toggle2FA,
                    activeColor: kPrimaryColor,
                  ),
                ],
              ),
            ),
    );
  }
}
