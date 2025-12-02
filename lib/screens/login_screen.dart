import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- استيراد Firebase Auth
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
  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. محاولة تسجيل الدخول في Firebase
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // 2. إذا نجح تسجيل الدخول، انتقل إلى الشاشة الرئيسية (Main Screen)
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      } on FirebaseAuthException catch (e) {
        // 3. التعامل مع أخطاء Firebase (مثل كلمة مرور خاطئة أو مستخدم غير موجود)
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        } else {
          errorMessage = 'Login failed. Check your credentials.';
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
                    : _signIn, // استدعاء دالة تسجيل الدخول
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
