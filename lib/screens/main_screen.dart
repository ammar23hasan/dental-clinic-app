import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/appointment_model.dart';
import 'notifications_sheet.dart';
import '../providers/locale_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Color primaryColor = kPrimaryColor;

  // دالة لتحديد رسالة الترحيب بناءً على الوقت
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  // بيانات وهمية للمواعيد القادمة
  final List<Appointment> _upcomingAppointments = [
    Appointment(
      id: 'A001',
      service: 'Regular Checkup',
      date: 'Oct 15, 2025',
      time: '10:00 AM',
      doctorName: 'Dr. Sarah Johnson',
      clinicAddress: '123 Health Street, Medical District',
      status: 'Confirmed',
      duration: '30 minutes',
    ),
    Appointment(
      id: 'A002',
      service: 'Dental Cleaning',
      date: 'Oct 22, 2025',
      time: '2:30 PM',
      doctorName: 'Dr. Michael Chen',
      clinicAddress: '123 Health Street, Medical District',
      status: 'Pending',
      duration: '45 minutes',
    ),
  ];

  // بيانات الخدمات الشائعة مع الأيقونات والأسعار
  final List<Map<String, dynamic>> _popularServices = const [
    {
      'name': 'Regular Checkup',
      'duration': '30 min',
      'price': '75',
      'icon': Icons.healing,
    },
    {
      'name': 'Dental Cleaning',
      'duration': '45 min',
      'price': '120',
      'icon': Icons.clean_hands,
    },
    {
      'name': 'Teeth Whitening',
      'duration': '60 min',
      'price': '200',
      'icon': Icons.star,
    },
    {
      'name': 'Root Canal',
      'duration': '90 min',
      'price': '450',
      'icon': Icons.medical_services,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ********** الهيدر والترحيب (SliverAppBar) **********
            SliverAppBar(
              floating: true,
              pinned: false,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(), // رسالة الترحيب الديناميكية
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const Text(
                    'Ammar Hasan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              actions: [
                // Language switcher popup
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: PopupMenuButton<String>(
                    tooltip: 'Language',
                    icon: const Icon(Icons.language, color: Colors.grey),
                    onSelected: (value) {
                      final provider = Provider.of<LocaleProvider>(context, listen: false);
                      if (value == 'en') {
                        provider.setLocale(const Locale('en'));
                      } else if (value == 'ar') {
                        provider.setLocale(const Locale('ar'));
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'en',
                        child: Row(
                          children: const [
                            Text('English'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'ar',
                        child: Row(
                          children: const [
                            Text('العربية'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    _showNotificationsSheet(context); // تفعيل شيت الإشعارات
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.2),
                    child: IconButton(
                      icon: Icon(Icons.person, color: primaryColor),
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ),
                ),
              ],
            ),

            // ********** قائمة العناصر المتبقية (SliverList) **********
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),

                // 1. قسم الخدمات السريعة (Quick Services)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildQuickActionButton(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Book Appointment',
                        subtitle: 'Schedule your next visit',
                        color: primaryColor,
                        isPrimary: true,
                      ),
                      const SizedBox(height: 15),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.access_time,
                        title: 'My Appointments',
                        subtitle: 'View upcoming visits',
                        color: Colors.grey.shade100,
                        isPrimary: false,
                      ),
                      const SizedBox(height: 15),
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                // عرض قائمة المواعيد (استخدام موديل البيانات)
                ..._upcomingAppointments
                    .map(
                      (appointment) =>
                          _buildAppointmentTile(context, appointment),
                    )
                    ,

                const SizedBox(height: 30),

                // 3. قسم الخدمات الشائعة (Popular Services)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Popular Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                // ********** شريط التمرير الأفقي الجديد **********
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _popularServices.length,
                    itemBuilder: (context, index) {
                      final service = _popularServices[index];
                      return _buildServiceCardHorizontal(context, service);
                    },
                  ),
                ),

                // **********************************************
                const SizedBox(height: 50),
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

  // دالة لفتح شيت الإشعارات
  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const FractionallySizedBox(
          heightFactor: 0.60,
          child: NotificationsSheet(),
        );
      },
    );
  }

  // دالة لبناء الأزرار السريعة (Quick Actions)
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isPrimary,
  }) {
    // تحديد منطق التنقل بناءً على العنوان
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

    final theme = Theme.of(context);
    // Use theme-aware colors for non-primary cards so they adapt to dark/light modes
    final Color backgroundColor =
        isPrimary ? primaryColor.withOpacity(0.9) : theme.cardColor;
    final Color iconContainerColor = isPrimary
        ? Colors.white
        : theme.colorScheme.primary.withOpacity(0.08);
    final Color iconColor = isPrimary
        ? theme.colorScheme.primary
        : theme.colorScheme.primary;
    final Color titleColor = isPrimary
        ? Colors.white
        : (theme.textTheme.titleLarge?.color ?? theme.textTheme.bodyLarge?.color ?? Colors.black);
    final Color? subtitleColor = isPrimary
        ? Colors.white70
        : (theme.textTheme.bodySmall?.color ?? Colors.grey[600]);
    final Color arrowColor = isPrimary
        ? Colors.white
        : (theme.iconTheme.color ?? Colors.grey);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
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
          onTap: navigationTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconContainerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
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
                          color: titleColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: arrowColor,
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // دالة بناء بطاقة الموعد (مع تفعيل التنقل)
  Widget _buildAppointmentTile(BuildContext context, Appointment appointment) {
    Color statusColor = appointment.status == 'Confirmed'
        ? Colors.green
        : Colors.orange;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // التنقل الفعلي: يذهب إلى شاشة تفاصيل الموعد
        onTap: () {
          Navigator.pushNamed(
            context,
            '/appointmentDetails',
            arguments: appointment, // تمرير بيانات الموعد
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: primaryColor),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.service,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${appointment.date} at ${appointment.time}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Dr. ${appointment.doctorName}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appointment.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة بناء بطاقة الخدمة (للتمرير الأفقي)
  Widget _buildServiceCardHorizontal(
    BuildContext context,
    Map<String, dynamic> service,
  ) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            // التنقل إلى صفحة تفاصيل الخدمة عند الضغط
            Navigator.pushNamed(
              context,
              '/serviceDetails',
              arguments: service['name'],
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  service['icon'],
                  size: 30,
                  color: primaryColor.withOpacity(0.8),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service['duration'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${service['price']}',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
