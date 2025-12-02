// lib/main.dart (الكود المحدث بالكامل)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';

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
import 'screens/forgot_password_screen.dart';
import 'screens/reset_confirmation_screen.dart';
import 'screens/service_details_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/report_problem_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // expose the state so other widgets can call setThemeMode
  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void setThemeMode(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleProvider>(
      create: (_) {
        final provider = LocaleProvider();
        provider.loadLocale(); // load persisted locale
        return provider;
      },
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'Dental Clinic App',
            debugShowCheckedModeBanner: false,

            themeMode: _themeMode, 
            theme: ThemeData(
              primaryColor: kPrimaryColor,
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(
                color: Colors.white,
                iconTheme: IconThemeData(color: Colors.black),
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              primaryColor: kPrimaryColor,
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
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

            // ********** استخدام AuthGate كنقطة انطلاق **********
            home: const AuthGate(), 

            locale: localeProvider.locale, // important: apply selected locale
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Optional: let system decide when locale is null
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale == null) return supportedLocales.first;
              for (final supported in supportedLocales) {
                if (supported.languageCode == locale.languageCode) {
                  return supported;
                }
              }
              return supportedLocales.first;
            },

            // نستخدم المسارات فقط للتنقل الداخلي (PushNamed)
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
              '/appSettings': (context) => AppSettingsScreen(
                onThemeChange: (isDark) => MyApp.of(context)?.setThemeMode(isDark),
              ),
              '/helpSupport': (context) => const HelpSupportScreen(),
              '/changePassword': (context) => const ChangePasswordScreen(),
              '/privacyPolicy': (context) => const PrivacyPolicyScreen(),
              '/twoFactorAuth': (context) => const TwoFactorAuthScreen(),
              '/forgotPassword': (context) => const ForgotPasswordScreen(),
              '/resetPasswordConfirmation': (context) => const ResetConfirmationScreen(),
              '/faqScreen': (context) => const FaqScreen(),
              '/reportProblemScreen': (context) => const ReportProblemScreen(),
              '/serviceDetails': (context) {
                final serviceName = ModalRoute.of(context)?.settings.arguments as String? ?? 'Service Details';
                return ServiceDetailsScreen(serviceName: serviceName);
              },
            },
          );
        },
      ),
    );
  }
}

// ********** كلاس AuthGate الجديد **********
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder يستمع لحالة تسجيل الدخول (تسجيل الدخول/الخروج)
    return StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator(color: kPrimaryColor)));
      }
      if (snapshot.hasData && snapshot.data != null) {
        return const MainScreen();
      }
      return const LoginScreen();
    });
  }
}
// ********************************************
