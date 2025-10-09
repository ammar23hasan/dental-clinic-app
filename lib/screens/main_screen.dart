// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import '../constants.dart'; // مسار ملف الثوابت

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // اللون الأزرق الرئيسي المستخدم في التطبيق
  final Color primaryColor = kPrimaryColor; // لون أزرق فاتح

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // الهيدر والترحيب (SliverAppBar)
            SliverAppBar(
              floating: true,
              pinned: false,
              elevation: 0,
              backgroundColor: Colors.white,
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    'Ammar Hasan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    // TODO: الذهاب إلى شاشة الإشعارات
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.2),
                    child: IconButton(
                      icon: Icon(Icons.person, color: primaryColor),
                      onPressed: () {
                        // التنقل: يذهب إلى شاشة الملف الشخصي
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ),
                ),
              ],
            ),

            // قائمة العناصر المتبقية (SliverList)
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),

                // 1. قسم الخدمات السريعة (Quick Services)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // زر حجز الموعد
                      _buildQuickActionButton(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Book Appointment',
                        subtitle: 'Schedule your next visit',
                        color: primaryColor,
                        isPrimary: true,
                      ),
                      const SizedBox(height: 15),
                      // زر مواعيدي
                      _buildQuickActionButton(
                        context,
                        icon: Icons.access_time,
                        title: 'My Appointments',
                        subtitle: 'View upcoming visits',
                        color: Colors.grey.shade100,
                        isPrimary: false,
                      ),
                      const SizedBox(height: 15),
                      // زر خدمات العيادة
                      _buildQuickActionButton(
                        context,
                        icon: Icons.medical_services_outlined,
                        title: 'Clinic Services',
                        subtitle: 'Explore our treatments',
                        color: Colors.grey.shade100,
                        isPrimary: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 2. قسم المواعيد القادمة (Upcoming Appointments)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Upcoming Appointments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // بطاقة الموعد الأول (قابلة للضغط)
                _buildAppointmentCard(
                  context,
                  title: 'Regular Checkup',
                  date: 'Aug 15, 2025 at 10:00 AM',
                  doctor: 'Dr. Sarah Johnson',
                  status: 'Confirmed',
                  statusColor: Colors.green,
                ),
                // بطاقة الموعد الثاني (قابلة للضغط)
                _buildAppointmentCard(
                  context,
                  title: 'Dental Cleaning',
                  date: 'Aug 22, 2025 at 2:30 PM',
                  doctor: 'Dr. Michael Chen',
                  status: 'Pending',
                  statusColor: Colors.orange,
                ),

                const SizedBox(height: 30),

                // 3. قسم الخدمات الشائعة (Popular Services)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Popular Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.2,
                    children: [
                      _buildServiceCard(
                        context,
                        'Regular Checkup',
                        '30 min',
                        '\$75',
                      ),
                      _buildServiceCard(
                        context,
                        'Dental Cleaning',
                        '45 min',
                        '\$120',
                      ),
                      _buildServiceCard(
                        context,
                        'Teeth Whitening',
                        '60 min',
                        '\$200',
                      ),
                      _buildServiceCard(
                        context,
                        'Root Canal',
                        '90 min',
                        '\$450',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // الدوال المساعدة (Helper Widgets)
  // -------------------------------------------------------------------

  // دالة لبناء الأزرار السريعة في الجزء العلوي (مع منطق التنقل)
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isPrimary,
  }) {
    // تحديد منطق التنقل بناءً على عنوان الزر
    VoidCallback navigationTap;
    if (title == 'Book Appointment') {
      navigationTap = () {
        Navigator.pushNamed(context, '/bookAppointment');
      };
    } else if (title == 'My Appointments') {
      navigationTap = () {
        Navigator.pushNamed(context, '/myAppointments');
      };
    } else if (title == 'Clinic Services') {
      navigationTap = () {
        Navigator.pushNamed(context, '/clinicServices');
      };
    } else {
      navigationTap = () {};
    }

    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? primaryColor.withOpacity(0.9) : color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: navigationTap, // استخدام منطق التنقل
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white
                        : primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isPrimary ? primaryColor : primaryColor,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isPrimary ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isPrimary ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isPrimary ? Colors.white : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لبناء بطاقات المواعيد القادمة (مع تفعيل التنقل)
  Widget _buildAppointmentCard(
    BuildContext context, {
    required String title,
    required String date,
    required String doctor,
    required String status,
    required Color statusColor,
  }) {
    return InkWell(
      // التنقل: يذهب إلى شاشة تفاصيل الموعد
      onTap: () {
        Navigator.pushNamed(context, '/appointmentDetails');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة التقويم
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              // تفاصيل الموعد
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // حالة الموعد
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لبناء بطاقات الخدمات الشائعة
  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String duration,
    String price,
  ) {
    return InkWell(
      // عند الضغط على خدمة شائعة، يمكن أن يذهب إلى شاشة حجز الموعد
      onTap: () {
        Navigator.pushNamed(context, '/bookAppointment');
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              duration,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
