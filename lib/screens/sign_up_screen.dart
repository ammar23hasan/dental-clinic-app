import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // حزمة المصادقة من Firebase
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- جديد: لحفظ بيانات المستخدم
import '../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(); // <--- جديد
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose(); // <--- جديد
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // دالة إنشاء الحساب في Firebase (محدثة لحفظ بيانات المستخدم في Firestore)
  void _createAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. إنشاء المستخدم باستخدام البريد وكلمة المرور
        final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // 2. حفظ البيانات الإضافية في Firestore
        if (userCredential.user != null) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
              'fullName': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'phoneNumber': '',
              'createdAt': FieldValue.serverTimestamp(),
            });
          } on FirebaseException catch (fsErr) {
            // specific handling for permission errors
            if (fsErr.code == 'permission-denied') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permission denied writing user data. Check Firestore security rules and project configuration.'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save user profile: ${fsErr.message}'), backgroundColor: Colors.red),
              );
            }
            // rethrow if you want to stop further navigation
            return;
          }
        }

        // 3. إذا نجح التسجيل، ننتقل إلى الشاشة الرئيسية (Main Screen)
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      } on FirebaseAuthException catch (e) {
        // 3. التعامل مع أخطاء Firebase (مثل 'email-already-in-use')
        String errorMessage;
        if (e.code == 'weak-password') {
          errorMessage =
              'The password provided is too weak (min 6 characters).';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for that email.';
        } else {
          errorMessage = 'Registration failed: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // دالة مساعدة لإنشاء أزرار التسجيل الاجتماعي (بقية الكود)
  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.black),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = kPrimaryColor; // استخدام الثابت kPrimaryColor

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
        elevation: 0,
        // زر العودة
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // المسافة العلوية
              const SizedBox(height: 50),

              // العنوان (Dental Clinic)
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Dental',
                      style: TextStyle(color: primaryColor),
                    ),
                    const TextSpan(
                      text: ' Clinic',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Create an account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                'Enter your email and password to sign up.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ), // تم تحديث الرسالة

              const SizedBox(height: 40),

              // ********** حقل الاسم الجديد **********
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter your full name' : null,
              ),

              const SizedBox(height: 15),
              // **********************************

              // ********** حقل البريد الإلكتروني **********
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'email@domain.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                validator: (value) => (value == null || !value.contains('@') || !value.contains('.')) ? 'Enter a valid email' : null,
              ),

              const SizedBox(height: 15),

              // ********** حقل كلمة المرور (جديد) **********
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password (min 6 characters)',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) => (value == null || value.length < 6)
                    ? 'Password must be at least 6 characters'
                    : null,
              ),

              // ********************************************
              const SizedBox(height: 15),

              // ********** زر المتابعة (Continue) **********
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _createAccount, // تعطيل الزر أثناء التحميل
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 30),
              const Center(
                child: Text('or', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 30),

              // زر المتابعة مع جوجل (Google)
              _buildSocialButton(
                text: 'Continue with Google',
                icon: Icons.g_mobiledata_sharp,
                onPressed: () {
                  // TODO: منطق التسجيل عبر جوجل
                },
                backgroundColor: const Color(0xFFF0F0F0),
                textColor: Colors.black,
              ),

              const SizedBox(height: 15),

              // زر المتابعة مع آبل (Apple)
              _buildSocialButton(
                text: 'Continue with Apple',
                icon: Icons.apple,
                onPressed: () {
                  // TODO: منطق التسجيل عبر آبل
                },
                backgroundColor: const Color(0xFFF0F0F0),
                textColor: Colors.black,
              ),

              const SizedBox(height: 40),

              // نص شروط الخدمة والخصوصية
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    const Text(
                      'By clicking continue, you agree to our',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Terms of Service',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Text(
                          'and',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
