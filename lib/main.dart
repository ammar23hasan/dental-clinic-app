import 'package:flutter/material.dart';

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

// ********** 1. الدالة الرئيسية **********
void main() {
  runApp(const MyApp());
}

// ********** 2. التطبيق الرئيسي **********
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dental Clinic App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        fontFamily: 'Roboto', // يمكنك تحديد خط موحد هنا
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        useMaterial3: true,
      ),

      // ********** 3. تعريف المسارات (Routes) **********
      // المسار الافتراضي (الشاشة الأولى عند تشغيل التطبيق)
      initialRoute: '/login',

      routes: {
        // شاشات المصادقة (Authentication)
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),

        // الشاشة الرئيسية
        '/main': (context) => const MainScreen(),

        // شاشات المواعيد
        '/bookAppointment': (context) =>
            const BookAppointmentScreen(), // تأكد من صحة المسار
        '/appointmentDetails': (context) => const AppointmentDetailsScreen(),

        // شاشات الملف الشخصي
        '/profile': (context) => const ProfileScreen(), // تأكد من صحة المسار
        '/editProfile': (context) => const EditProfileScreen(),
        '/myAppointments': (context) =>
            const MyAppointmentsScreen(), // Ensure this route is correct
        '/clinicServices': (context) =>
            const ClinicServicesScreen(), // Ensure this route is correct
      },
    );
  }
}

// -----------------------------------------------------------
// ********** 4. أمثلة على كيفية الربط داخل الشاشات **********
// -----------------------------------------------------------

// يجب وضع هذا المنطق داخل الدوال onPressed في الشاشات
// على سبيل المثال:

/*
// داخل ملف login_screen.dart
// عند الضغط على زر "Sign In":
onPressed: () {
  // للذهاب إلى الشاشة الرئيسية وإزالة كل المسارات السابقة
  Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
},

// عند الضغط على زر "Sign up" في شاشة تسجيل الدخول:
onPressed: () {
  // للذهاب إلى شاشة التسجيل
  Navigator.pushNamed(context, '/signup'); 
},


// داخل ملف main_screen.dart
// عند الضغط على زر "Book Appointment":
onTap: () {
  // للذهاب إلى شاشة حجز الموعد
  Navigator.pushNamed(context, '/bookAppointment');
},

// عند الضغط على أيقونة الملف الشخصي في الهيدر:
onPressed: () {
  // للذهاب إلى شاشة الملف الشخصي
  Navigator.pushNamed(context, '/profile');
},

// داخل ملف profile_screen.dart
// عند الضغط على زر التعديل (القلم):
onPressed: () {
  // للذهاب إلى شاشة تعديل الملف الشخصي
  Navigator.pushNamed(context, '/editProfile');
},
*/
