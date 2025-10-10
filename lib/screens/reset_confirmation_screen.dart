// lib/screens/reset_confirmation_screen.dart

import 'package:flutter/material.dart';
import '../constants.dart';

class ResetConfirmationScreen extends StatelessWidget {
  const ResetConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب البريد الإلكتروني الممرر
    final email = ModalRoute.of(context)!.settings.arguments as String? ?? 'your email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        automaticallyImplyLeading: false, // لا نريد زر العودة هنا
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
              const SizedBox(height: 30),

              const Text(
                'Check Your Inbox',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'We have sent a password reset link to:\n$email. Please check your spam folder as well.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 50),
              
              // زر العودة إلى تسجيل الدخول
              ElevatedButton(
                onPressed: () {
                  // التنقل: العودة إلى شاشة تسجيل الدخول
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                child: const Text('Back to Sign In', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}