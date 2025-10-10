// lib/main.dart (الكود المحدث بالكامل)

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

// استيراد الشاشات وملف الثوابت
import 'constants.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/main_screen.dart';
import 'screens/book_appointment_screen.dart';
import 'screens/appointment_details_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/my_appointments_screen.dart';
import 'screens/clinic_services_screen.dart';
import 'screens/notifications_settings_screen.dart';
import 'screens/privacy_security_screen.dart';
import 'screens/app_settings_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/two_factor_auth_screen.dart';
import 'screens/forgot_password_screen.dart'; // <--- إضافة الاستيراد
import 'screens/reset_confirmation_screen.dart';
import 'screens/service_details_screen.dart'; // <--- إضافة الاستيراد الجديد
import 'screens/faq_screen.dart';
import 'screens/report_problem_screen.dart';

void main() {
  runApp(const MyApp());
}

// تم تحويلها إلى StatefulWidget لإدارة ThemeMode
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // هذه الدالة تسمح بالوصول إلى الـ State من أي مكان (لتغيير الثيم)
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // المتغير الذي يتحكم في مظهر التطبيق
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode(); // تحميل الثيم المحفوظ عند بدء التطبيق
  }

  // تحميل الثيم من shared_preferences
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isDark = prefs.getBool('darkMode') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // الدالة التي تستدعيها شاشة الإعدادات لتغيير الثيم
  void setThemeMode(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    // يتم حفظ القيمة داخل شاشة AppSettingsScreen
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dental Clinic App',
      debugShowCheckedModeBanner: false,

      // ********** الإضافة الجديدة لـ ThemeMode **********
      themeMode: _themeMode, // <--- يتحكم في الوضع الحالي (Light/Dark)
      theme: ThemeData(
        // إعدادات الوضع الفاتح
        primaryColor: kPrimaryColor,
        primarySwatch: Colors.blue, // للتحكم في الألوان الأساسية
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        // إعدادات الوضع الداكن
        primaryColor: kPrimaryColor,
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        // يمكنك تخصيص الألوان الداكنة هنا
        appBarTheme: AppBarTheme(
          color: Colors.grey.shade900,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor: Colors.grey.shade900,
        cardColor: Colors.grey.shade800,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        useMaterial3: true,
      ),

      // ********** تعريف المسارات (Routes) **********
      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/main': (context) => const MainScreen(),
        '/bookAppointment': (context) => const BookAppointmentScreen(),
        '/appointmentDetails': (context) => const AppointmentDetailsScreen(),
        '/myAppointments': (context) => const MyAppointmentsScreen(),
        '/clinicServices': (context) => const ClinicServicesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/editProfile': (context) => const EditProfileScreen(),
        '/notifications': (context) => const NotificationsSettingsScreen(),
        '/privacySecurity': (context) => const PrivacySecurityScreen(),
        // نمرر دالة التغيير كمعامل لتمكين شاشة الإعدادات من التحكم بالثيم
        '/appSettings': (context) => AppSettingsScreen(
          onThemeChange: (isDark) => MyApp.of(context).setThemeMode(isDark),
        ),
        '/helpSupport': (context) => const HelpSupportScreen(),
        '/changePassword': (context) => const ChangePasswordScreen(),
        '/privacyPolicy': (context) => const PrivacyPolicyScreen(),
        '/twoFactorAuth': (context) => const TwoFactorAuthScreen(),
        '/clinicServices': (context) => const ClinicServicesScreen(),
        // المسارات الإضافية للمساعدة
        '/faqScreen': (context) => const FaqScreen(), // <--- المسار الجديد
        '/reportProblemScreen': (context) =>
            const ReportProblemScreen(), // <--- المسار الجديد
        '/forgotPassword': (context) =>
            const ForgotPasswordScreen(), // <--- تأكد من وجود هذا المسار
        '/resetPasswordConfirmation': (context) =>
            const ResetConfirmationScreen(),
        // **المسار المحدث:** لقبول المعامل وتمريره إلى مُنشئ الشاشة
        '/serviceDetails': (context) {
          final serviceName =
              ModalRoute.of(context)?.settings.arguments as String? ??
              'Service Details';
          return ServiceDetailsScreen(serviceName: serviceName);
        },
      },
    );
  }
}
