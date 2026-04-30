// lib/main.dart (الكود المحدث بالكامل)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
import 'screens/admin_services_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler must initialize Firebase
  await Firebase.initializeApp();
  // Optional: handle background message payload/log
  print('Handling a background message: ${message.messageId}, data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register the background handler (must be after Firebase initialization)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

// NotificationService: init permissions, save token to users/{uid}, listen token refresh and show local notifications on foreground
class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // Android channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  // Call once at app startup
  static Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: ios);
    await _local.initialize(initSettings);
    // Create channel on Android
    try {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    } catch (_) {}
  }

  // Request permission, get token and save to Firestore, setup foreground listener and token refresh listener
  static Future<void> initAndSaveToken() async {
    await initLocalNotifications();

    // 1. request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('User declined notification permissions');
      return;
    }

    // 2. get token
    final token = await _fcm.getToken();
    print('FCM Token: $token');

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }

    // 3. listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'fcmToken': newToken}, SetOptions(merge: true));
      }
    });

    // 4. show foreground notifications using flutter_local_notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = message.notification;
      final android = message.notification?.android;
      final title = notif?.title ?? '';
      final body = notif?.body ?? '';
      // display local notification
      _local.show(
        // id
        title.hashCode ^ body.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );
    });
  }
}

// Replace MyApp StatelessWidget with StatefulWidget to react to auth changes and initialize notifications when user signs in
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    // Listen to auth state and initialize notifications when user is present
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          await NotificationService.initAndSaveToken();
        } catch (e) {
          print('NotificationService.initAndSaveToken error: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

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
        '/adminServices': (context) => const AdminServicesScreen(),
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
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return ServiceDetailsScreen(service: args);
          }

          final serviceName = args as String? ?? 'Service Details';
          return ServiceDetailsScreen(service: {'name': serviceName});
        },
      },
    );
  }
}
  