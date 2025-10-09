import 'package:flutter/material.dart';
import '../constants.dart'; // مسار ملف الثوابت

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color primaryColor = kPrimaryColor; // اللون الأزرق الأساسي

  // المتحكمات لـ TextFields
  final TextEditingController _nameController = TextEditingController(
    text: 'Ammar Hasan',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'ammarhasan@gmail.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+1 (555) 123-4567',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    print('Saving changes...');
    print('New Name: ${_nameController.text}');
    print('New Email: ${_emailController.text}');
    print('New Phone: ${_phoneController.text}');
    Navigator.pop(context); // العودة إلى صفحة الملف الشخصي
  }

  void _cancelEdit() {
    // TODO: منطق إلغاء التعديلات (قد تحتاج إلى إعادة تعيين الحقول الأصلية)
    Navigator.pop(context); // العودة للشاشة السابقة
  }

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
          onPressed: _cancelEdit,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),

              // ********** 1. قسم حقول الإدخال (البطاقة الزرقاء) **********
              _buildEditProfileCard(),
              const SizedBox(height: 40),

              // ********** 2. أزرار الإجراءات **********
              Row(
                children: [
                  // زر حفظ التغييرات
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // زر إلغاء
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelEdit,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(
                          color: primaryColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: primaryColor,
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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

  // بناء بطاقة تعديل الملف الشخصي
  Widget _buildEditProfileCard() {
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
      child: Column(
        children: [
          const Icon(Icons.person_outline, size: 40, color: Colors.white),
          const SizedBox(height: 20),
          _buildProfileTextField(
            _nameController,
            hint: 'Full Name',
            keyboardType: TextInputType.name,
          ),
          _buildProfileTextField(
            _emailController,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          _buildProfileTextField(
            _phoneController,
            hint: 'Phone',
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  // بناء حقل إدخال مخصص ليتناسب مع التصميم الأزرق
  Widget _buildProfileTextField(
    TextEditingController controller, {
    required String hint,
    required TextInputType keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.normal,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.lightBlueAccent,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
