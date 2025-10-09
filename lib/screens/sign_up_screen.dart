import 'package:flutter/material.dart';
import '../constants.dart'; // مسار ملف الثوابت
// يمكن تسمية الملف sign_up_screen.dart

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تحديد اللون الأساسي
    const Color primaryColor = Color(0xFF1E88E5); // لون أزرق قريب من التصميم

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
        automaticallyImplyLeading: false, // لإزالة زر الرجوع إذا لزم الأمر
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // المسافة العلوية
            const SizedBox(height: 50),

            // العنوان (Dental Clinic)
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Dental',
                    style: TextStyle(color: primaryColor), // اللون الأزرق
                  ),
                  TextSpan(
                    text: ' Clinic',
                    style: TextStyle(color: Colors.black), // اللون الأسود
                  ),
                ],
              ),
            ),

            // المسافة
            const SizedBox(height: 20),

            // نص "Create an account"
            const Text(
              'Create an account',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // نص التوضيحي
            const SizedBox(height: 5),
            const Text(
              'Enter your email to sign up for this app',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            // المسافة
            const SizedBox(height: 40),

            // حقل إدخال البريد الإلكتروني
            TextFormField(
              decoration: InputDecoration(
                hintText: 'email@domain.com',
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18.0,
                  horizontal: 20.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            // المسافة
            const SizedBox(height: 15),

            // زر المتابعة (Continue)
            ElevatedButton(
              onPressed: () {
                // TODO: أضف منطق التحقق والمتابعة هنا
                print('Continue with Email tapped');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // المسافة
            const SizedBox(height: 30),

            // فاصل "or"
            const Center(
              child: Text('or', style: TextStyle(color: Colors.grey)),
            ),

            // المسافة
            const SizedBox(height: 30),

            // زر المتابعة مع جوجل (Google)
            _buildSocialButton(
              text: 'Continue with Google',
              icon:
                  Icons.g_mobiledata_sharp, // يمكنك استخدام أيقونة جوجل الفعلية
              onPressed: () {
                // TODO: أضف منطق التسجيل عبر جوجل هنا
                print('Continue with Google tapped');
              },
              backgroundColor: const Color(0xFFF0F0F0),
              textColor: Colors.black,
            ),

            // المسافة
            const SizedBox(height: 15),

            // زر المتابعة مع آبل (Apple)
            _buildSocialButton(
              text: 'Continue with Apple',
              icon: Icons.apple,
              onPressed: () {
                // TODO: أضف منطق التسجيل عبر آبل هنا
                print('Continue with Apple tapped');
              },
              backgroundColor: const Color(0xFFF0F0F0),
              textColor: Colors.black,
            ),

            // المسافة
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
                        onPressed: () {
                          // TODO: فتح صفحة شروط الخدمة
                        },
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
                        onPressed: () {
                          // TODO: فتح صفحة سياسة الخصوصية
                        },
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

            // المسافة السفلية
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لإنشاء أزرار التسجيل الاجتماعي
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
}
