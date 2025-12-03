import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _AppointmentsTab(),
      const _PatientsTab(),
      const _DoctorsTab(),
      const _AdminSettingsTab(),
    ];

    final pageTitles = [
      'Appointments',
      'Patients',
      'Doctors',
      'Admin Settings',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 1) تبويب المواعيد
/// =======================
class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // تعديل أسماء الحقول حسب ما عندك في appointments
    final query = FirebaseFirestore.instance
        .collection('appointments')
        .orderBy('date', descending: false);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading appointments: ${snapshot.error}'),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Text('No appointments found.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final data = docs[index].data();

            final patientName =
                (data['patientName'] ?? 'Unknown patient').toString();
            final doctorName =
                (data['doctorName'] ?? 'Unknown doctor').toString();
            final status = (data['status'] ?? 'Pending').toString();

            // نفترض أن التاريخ مخزّن كـ Timestamp في حقل "date"
            String dateText = '-';
            final rawDate = data['date'];
            if (rawDate is Timestamp) {
              final dt = rawDate.toDate();
              dateText =
                  '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}'
                  '  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            } else if (rawDate is String) {
              dateText = rawDate; // لو مخزّن كنص
            }

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: kPrimaryColor.withOpacity(0.1),
                  child: const Icon(Icons.event_note, color: kPrimaryColor),
                ),
                title: Text(
                  patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Doctor: $doctorName'),
                    const SizedBox(height: 2),
                    Text('Date: $dateText'),
                    const SizedBox(height: 2),
                    Text('Status: $status'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    // لاحقاً: تعديل حالة الموعد مثلاً
                    // if (value == 'approve') ...
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'approve',
                      child: Text('Approve'),
                    ),
                    PopupMenuItem(
                      value: 'cancel',
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// =======================
/// 2) تبويب المرضى (Placeholder حالياً)
/// =======================
class _PatientsTab extends StatelessWidget {
  const _PatientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // لاحقاً: قراءة users من Firestore حيث role = "Patient"
    return const Center(
      child: Text(
        'Patients management will be implemented here.',
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// =======================
/// 3) تبويب الأطباء (Placeholder حالياً)
/// =======================
class _DoctorsTab extends StatelessWidget {
  const _DoctorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // لاحقاً: عرض قائمة الأطباء من collection doctors مثلاً
    return const Center(
      child: Text(
        'Doctors management will be implemented here.',
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// =======================
/// 4) تبويب إعدادات الأدمن
/// =======================
class _AdminSettingsTab extends StatelessWidget {
  const _AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Info',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Email: ${user?.email ?? '-'}'),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // يرجع لشاشة تسجيل الدخول ويمسح الهيستوري
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // مثال: رجوع للتطبيق العادي من منظور الأدمن
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
            },
            icon: const Icon(Icons.phone_iphone),
            label: const Text('Open Patient App View'),
          ),
        ],
      ),
    );
  }
}
