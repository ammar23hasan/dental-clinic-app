// lib/main.dart (الكود المحدث بالكامل)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';

// استيراد الشاشات وملف الثوابت
import 'constants.dart';
import 'screens/doctor_dashboard.dart';
import 'screens/admin_dashboard.dart';
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
import 'screens/forgot_password_screen.dart';
import 'screens/reset_confirmation_screen.dart';
import 'screens/service_details_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/report_problem_screen.dart';
import 'screens/doctor_edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<LocaleProvider>(create: (_) {
          final provider = LocaleProvider();
          provider.loadLocale();
          return provider;
        }),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Dental Clinic App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primaryColor: kPrimaryColor,
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade900,
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
      // نبدأ من شاشة تسجيل الدخول
      home: const LoginScreen(),

      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routes: {
        '/doctor-edit-profile': (context) => const DoctorEditProfileScreen(),
        '/login': (context) => const LoginScreen(),
        '/doctorDashboard': (context) => const DoctorDashboard(),
        '/signup': (context) => const SignUpScreen(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/main': (context) => const MainScreen(),
        '/bookAppointment': (context) => const BookAppointmentScreen(),
        '/appointmentDetails': (context) => const AppointmentDetailsScreen(),
        '/myAppointments': (context) => const MyAppointmentsScreen(),
        '/clinicServices': (context) => const ClinicServicesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/editProfile': (context) => const EditProfileScreen(),
        '/notifications': (context) => const NotificationsSettingsScreen(),
        '/privacySecurity': (context) => const PrivacySecurityScreen(),
        '/appSettings': (context) => AppSettingsScreen(
              onThemeChange: (isDark) =>
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme(isDark),
            ),
        '/helpSupport': (context) => const HelpSupportScreen(),
        '/changePassword': (context) => const ChangePasswordScreen(),
        '/privacyPolicy': (context) => const PrivacyPolicyScreen(),
        '/twoFactorAuth': (context) => const TwoFactorAuthScreen(),
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
        '/resetPasswordConfirmation': (context) =>
            const ResetConfirmationScreen(),
        '/faqScreen': (context) => const FaqScreen(),
        '/reportProblemScreen': (context) => const ReportProblemScreen(),
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
