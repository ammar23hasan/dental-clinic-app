// lib/screens/change_password_screen.dart (الكود المطور)

import 'package:flutter/material.dart';
import '../constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  // يمكن استخدام متغيرات التحكم (Controllers) للحصول على القيم
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _submitChange(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // التحقق من تطابق كلمتي المرور الجديدتين
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match!')),
        );
        return;
      }

      // TODO: إضافة منطق إرسال كلمة المرور القديمة والجديدة إلى الخادم
      print('Password change request submitted!');

      // إظهار رسالة نجاح والعودة للخلف
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );
      Navigator.pop(context); // العودة إلى الشاشة السابقة
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // حقل كلمة المرور القديمة
              _buildPasswordField(_oldPasswordController, 'Current Password'),
              const SizedBox(height: 20),

              // حقل كلمة المرور الجديدة
              _buildPasswordField(
                _newPasswordController,
                'New Password',
                isNew: true,
              ),
              const SizedBox(height: 20),

              // حقل تأكيد كلمة المرور
              _buildPasswordField(
                _confirmPasswordController,
                'Confirm New Password',
              ),
              const SizedBox(height: 40),

              // زر الحفظ
              ElevatedButton(
                onPressed: () => _submitChange(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label, {
    bool isNew = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock_outline),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required.';
        }
        if (isNew && value.length < 6) {
          return 'Password must be at least 6 characters long.';
        }
        return null;
      },
    );
  }
}
