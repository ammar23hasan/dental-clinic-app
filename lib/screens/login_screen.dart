import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- استيراد Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- استيراد Firestore
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // دالة تسجيل الدخول باستخدام Firebase
  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1) تسجيل الدخول
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'User object is null after login',
        );
      }

      print('LOGIN SUCCESS, UID = ${user.uid}');

      // 2) قراءة الدور من Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String role = 'Patient'; // default
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['role'] != null) {
          role = data['role'].toString();
        }
      }

      print('ROLE FROM FIRESTORE = $role');

      // 3) التوجيه حسب الدور
      final lower = role.toLowerCase();

      if (lower == 'admin') {
        // أدمن → لوحة تحكم الأدمن
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/adminDashboard',
          (route) => false,
        );
      } else if (lower == 'doctor') {
        // دكتور → لوحة تحكم الدكتور (تدعم التابليت)
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/doctorDashboard',
          (route) => false,
        );
      } else {
        // أي دور آخر → التطبيق العادي (المريض)
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      print('LOGIN ERROR = ${e.code} - ${e.message}');

      String message = 'Login failed. Please try again.';
      if (e.code == 'user-not-found') {
        message = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      print('UNEXPECTED LOGIN ERROR = $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    const Color primaryColor = kPrimaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // المسافة العلوية
              const SizedBox(height: 50),

              // الشعار
              Icon(
                Icons.person_pin,
                size: 100,
                color: primaryColor,
              ), // استخدام أيقونة وهمية
              // المسافة
              const SizedBox(height: 20),

              // النص الترحيبي
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),

              // النص التوضيحي
              const SizedBox(height: 8),
              const Text(
                'Sign in to your dental care account',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              // المسافة
              const SizedBox(height: 40),

              // ********** حقل البريد الإلكتروني **********
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || !value.contains('@'))
                    ? 'Enter a valid email'
                    : null,
              ),

              // المسافة
              const SizedBox(height: 20),

              // ********** حقل كلمة المرور **********
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  // زر عرض/إخفاء كلمة المرور
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                validator: (value) => (value == null || value.length < 6)
                    ? 'Password must be at least 6 characters'
                    : null,
              ),

              // المسافة
              const SizedBox(height: 10),

              // زر نسيت كلمة المرور
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // التنقل: يذهب إلى شاشة نسيت كلمة المرور
                    Navigator.pushNamed(context, '/forgotPassword');
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: kPrimaryColor),
                  ),
                ),
              ),

              // المسافة
              const SizedBox(height: 20),

              // ********** زر تسجيل الدخول **********
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _login, // استدعاء دالة تسجيل الدخول المحدثة
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: primaryColor, // لون الزر الأساسي
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Sign In',
                        style: TextStyle(color: Colors.white),
                      ),
              ),

              // المسافة
              const SizedBox(height: 20),

              // خيار ليس لديك حساب؟
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),

              // المسافة السفلية
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}