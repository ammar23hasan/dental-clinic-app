// lib/screens/change_password_screen.dart (الكود المحدث)

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final Color primaryColor = kPrimaryColor;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  
  // دالة تغيير كلمة المرور (المحدثة)
  void _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.'), backgroundColor: Colors.red),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in.'), backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. إعادة المصادقة باستخدام البريد وكلمة المرور القديمة
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // 2. تحديث كلمة المرور
      await user.updatePassword(_newPasswordController.text.trim());

      // 3. إظهار رسالة نجاح ثم تسجيل الخروج وإعادة التوجيه لشاشة الدخول
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully. Please sign in again.')),
        );
        await FirebaseAuth.instance.signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to change password: ${e.message}';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Current password is incorrect.';
      } else if (e.code == 'requires-recent-login') {
        errorMessage = 'Please re-login and try again.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'New password is too weak (min 6 characters).';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unexpected error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
         elevation: 1,
       ),
       body: SingleChildScrollView(
         padding: const EdgeInsets.all(20.0),
         child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Enter your current password and your new password to update your security settings.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),

              // حقل كلمة المرور الحالية
              _buildPasswordField(
                controller: _oldPasswordController,
                labelText: 'Current Password',
                validator: (value) => (value == null || value.isEmpty) ? 'Enter your current password.' : null,
              ),
              const SizedBox(height: 20),

              // حقل كلمة المرور الجديدة
              _buildPasswordField(
                controller: _newPasswordController,
                labelText: 'New Password',
                validator: (value) {
                  if (value == null || value.length < 6) return 'Password must be at least 6 characters.';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // حقل تأكيد كلمة المرور الجديدة
              _buildPasswordField(
                controller: _confirmPasswordController,
                labelText: 'Confirm New Password',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Confirm the new password.';
                  if (value != _newPasswordController.text) return 'New password and confirmation must match.';
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // زر التغيير
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Change Password',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لبناء حقول كلمة المرور
  Widget _buildPasswordField({
     required TextEditingController controller,
     required String labelText,
     String? Function(String?)? validator,
   }) {
     return TextFormField(
       controller: controller,
       obscureText: true,
       decoration: InputDecoration(
         labelText: labelText,
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
         prefixIcon: const Icon(Icons.lock),
       ),
       validator: validator,
     );
   }
}
