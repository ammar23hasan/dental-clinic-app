import 'package:flutter/material.dart';
import '../constants.dart'; // مسار ملف الثوابت
// يمكن تسمية الملف login_screen.dart

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // للتحكم في حالة عرض/إخفاء كلمة المرور
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    // يمكنك تعديل اللون الأساسي حسب تصميمك
    const Color primaryColor = Color(0xFF1E88E5); // لون أزرق مناسب

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        // لإزالة زر الرجوع إذا كان هذا هو الشاشة الرئيسية
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // المسافة العلوية
              const SizedBox(height: 50),

              // الشعار - تأكد من إضافة الصورة في assets وتحديث المسار
              Image.asset(
                'assets/images/logo.png', // **تأكد من أن الصورة موجودة في هذا المسار**
                height: 160,
              ),

              // المسافة
              const SizedBox(height: 20),

              // النص الترحيبي
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
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

              // حقل البريد الإلكتروني
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              // المسافة
              const SizedBox(height: 20),

              // حقل كلمة المرور
              TextFormField(
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
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

              // زر تسجيل الدخول
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/main',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: primaryColor, // لون الزر الأساسي
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text(
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
