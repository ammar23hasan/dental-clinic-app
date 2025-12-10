import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:characters/characters.dart';
import 'package:provider/provider.dart';
import 'doctor_patient_details_screen.dart'; // تأكد من المسار الصحيح
import 'dart:ui';

import '../constants.dart';
import '../providers/theme_provider.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 900; // breakpoint بسيط

    final pages = [
      const _DoctorOverviewTab(),
      const _DoctorAppointmentsTab(),
      const _DoctorPatientsTab(),
      const _DoctorSettingsTab(),
    ];

    final pageTitles = [
      'Overview',
      'Appointments',
      'Patients',
      'Settings',
    ];

    if (isTablet) {
      // 👇 وضع التابلت: NavigationRail + محتوى على اليمين
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              extended: size.width >= 1150, // لو الشاشة عريضة كثير يظهر النص
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedIconTheme: const IconThemeData(color: kPrimaryColor),
              selectedLabelTextStyle: const TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.event_note_outlined),
                  selectedIcon: Icon(Icons.event_note),
                  label: Text('Appointments'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_alt_outlined),
                  selectedIcon: Icon(Icons.people_alt),
                  label: Text('Patients'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
            // خط فاصل صغير
            Container(
              width: 0.5,
              color: Colors.grey.withOpacity(0.3),
            ),
            // محتوى الصفحة
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    pageTitles[_selectedIndex],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: false,
                ),
                body: pages[_selectedIndex],
              ),
            ),
          ],
        ),
      );
    } else {
      // 👇 وضع الموبايل: BottomNavigationBar عادي
      return Scaffold(
        appBar: AppBar(
          title: Text(
            pageTitles[_selectedIndex],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              label: 'Patients',
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
}

/// ============================
/// 1) تبويب Overview للطبيب
/// ============================
class _DoctorOverviewTab extends StatelessWidget {
  const _DoctorOverviewTab();

  DateTime? _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();

    if (raw is String) {
      // معظم مواعيدك بصيغة "April 24, 2025"
      try {
        return DateFormat('MMMM d, yyyy').parse(raw);
      } catch (_) {
        // لو الشكل مختلف نحاول نقرأ بدون فاصلة
        try {
          return DateFormat('MMMM d yyyy').parse(raw.replaceAll(',', ''));
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not logged in.'));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withOpacity(isDark ? 0.18 : 0.10),
            Theme.of(context).scaffoldBackgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          final data = userSnap.data?.data() ?? {};
          final doctorName = (data['fullName'] ?? user.email ?? 'Doctor').toString();

          // الآن نسمع لمواعيد هذا الدكتور
          final query = FirebaseFirestore.instance
              .collection('appointments')
              .where('doctor', isEqualTo: doctorName);

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: query.snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                );
              }

              final docs = snap.data?.docs ?? [];

              // ====== حساب الإحصائيات ======
              final now = DateTime.now();
              final startToday = DateTime(now.year, now.month, now.day);
              final start7Days = startToday.subtract(const Duration(days: 6));

              int todayCount = 0;
              int last7DaysCount = 0;
              double last7DaysRevenue = 0;
              final patientIds = <String>{};
              final serviceCounter = <String, int>{};
              final dailyCounts = <String, int>{}; // key: yyyy-MM-dd

              for (final doc in docs) {
                final d = doc.data();
                final status = (d['status'] ?? '').toString().toLowerCase();
                final serviceName = (d['serviceName'] ?? 'Service').toString();
                final userId = (d['userId'] ?? '').toString();

                final date = _parseDate(d['date']);
                if (date == null) continue;

                final key =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

                // نجمع عدد المواعيد في آخر ٧ أيام (مع استبعاد الملغاة)
                if (!status.contains('cancel')) {
                  if (!date.isBefore(start7Days) &&
                      !date.isAfter(startToday)) {
                    last7DaysCount++;
                    final price = double.tryParse(
                            d['price']?.toString() ?? '0') ??
                        0;
                    last7DaysRevenue += price;

                    dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
                  }

                  if (date.isAtSameMomentAs(startToday) ||
                      (date.isAfter(startToday) &&
                          date.isBefore(startToday.add(const Duration(days: 1))))) {
                    todayCount++;
                  }
                }

                if (userId.isNotEmpty) {
                  patientIds.add(userId);
                }

                serviceCounter[serviceName] =
                    (serviceCounter[serviceName] ?? 0) + 1;
              }

              String topService = 'No data yet';
              if (serviceCounter.isNotEmpty) {
                final entry = serviceCounter.entries.reduce(
                  (a, b) => a.value >= b.value ? a : b,
                );
                topService = '${entry.key} (${entry.value} bookings)';
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // بطاقة الترحيب
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            color: kPrimaryColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Good day, Doctor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doctorName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Here is a quick overview of your clinic activity.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Cards للإحصائيات
                  Row(
                    children: [
                      Expanded(
                        child: _DoctorStatCard(
                          label: 'Today',
                          value: todayCount.toString(),
                          icon: Icons.today_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DoctorStatCard(
                          label: 'Last 7 days',
                          value: last7DaysCount.toString(),
                          icon: Icons.calendar_view_week_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DoctorStatCard(
                          label: 'Patients',
                          value: patientIds.length.toString(),
                          icon: Icons.people_alt_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // دخل آخر ٧ أيام و الـ Top Service
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Insights',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Revenue (last 7 days): \$${last7DaysRevenue.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Top service: $topService',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Mini bar chart لآخر ٧ أيام
                  Text(
                    'Appointments (last 7 days)',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _MiniBarChart(
                    startDate: start7Days,
                    dailyCounts: dailyCounts,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
    }  
    }


class _DoctorStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DoctorStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(.05)
                : Colors.white.withOpacity(.35),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(.08)
                  : Colors.white.withOpacity(.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.blue.withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(2, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(.08)
                      : Colors.white.withOpacity(.65),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),

              // Value
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(height: 6),

              // Label
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _MiniBarChart extends StatelessWidget {
  final DateTime startDate; // أول يوم (من آخر ٧ أيام)
  final Map<String, int> dailyCounts;

  const _MiniBarChart({
    required this.startDate,
    required this.dailyCounts,
  });

  @override
  Widget build(BuildContext context) {
    final bars = <Widget>[];
    final maxCount =
        (dailyCounts.values.isNotEmpty ? dailyCounts.values.reduce((a, b) => a > b ? a : b) : 1)
            .toDouble();

    for (int i = 0; i < 7; i++) {
      final day = startDate.add(Duration(days: i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final count = (dailyCounts[key] ?? 0).toDouble();

      final height = (count == 0 ? 6.0 : 10 + (40 * (count / maxCount)));

      bars.add(
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: height,
                width: 14,
                decoration: BoxDecoration(
                  color: count > 0
                      ? kPrimaryColor.withOpacity(0.9)
                      : kPrimaryColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('E').format(day),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars,
      ),
    );
  }
}

/// ============================
/// 2) تبويب المواعيد للطبيب (Placeholder حالياً)
/// ============================
/// ============================
/// 2) تبويب المواعيد للطبيب (فعّال)
/// ============================
class _DoctorAppointmentsTab extends StatelessWidget {
  const _DoctorAppointmentsTab();

  Future<String?> _getDoctorName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!snap.exists) return null;

    final data = snap.data();
    final name = data?['fullName']?.toString();
    print('DoctorAppointmentsTab -> fullName from users = $name');
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getDoctorName(),
      builder: (context, nameSnapshot) {
        if (nameSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        }

        if (!nameSnapshot.hasData || nameSnapshot.data == null) {
          return const Center(
            child: Text('Doctor name not found for this account.'),
          );
        }

        final doctorName = nameSnapshot.data!;
        print('DoctorAppointmentsTab -> using doctor = $doctorName');

        // الحقل عندك اسمه "doctor" في appointments
        final query = FirebaseFirestore.instance
            .collection('appointments')
            .where('doctor', isEqualTo: doctorName);
        // مبدئياً بدون orderBy لتجنب مشكلة الـ index

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
            print('DoctorAppointmentsTab -> found ${docs.length} appointments');

            if (docs.isEmpty) {
              return const Center(
                child: Text('No appointments found for this doctor.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data();

                final patientName =
                    (data['patientName'] ?? 'Unknown patient').toString();
                final service =
                    (data['serviceName'] ?? 'Service').toString();
                final status =
                    (data['status'] ?? 'Pending').toString();

                String dateTxt = '—';
                final rawDate = data['date'];
                if (rawDate is Timestamp) {
                  final d = rawDate.toDate();
                  dateTxt =
                      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}  '
                      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
                } else if (rawDate is String) {
                  dateTxt = rawDate;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: kPrimaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$service • $dateTxt',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      _statusBadge(status),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'canceled':
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// ============================
/// 3) تبويب المرضى للطبيب (Placeholder)
/// ============================
/// ============================
/// 3) تبويب المرضى للطبيب (Patients)
/// ============================
class _DoctorPatientsTab extends StatelessWidget {
  const _DoctorPatientsTab();

  Future<String?> _getDoctorName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!snap.exists) return null;

    final data = snap.data();
    final name = data?['fullName']?.toString();
    print('DoctorPatientsTab -> fullName from users = $name');
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getDoctorName(),
      builder: (context, nameSnapshot) {
        if (nameSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
        }
        if (!nameSnapshot.hasData || nameSnapshot.data == null) {
          return const Center(child: Text('Doctor name not found for this account.'));
        }

        final doctorName = nameSnapshot.data!;
        print('DoctorPatientsTab -> using doctor = $doctorName');

        final query = FirebaseFirestore.instance.collection('appointments').where('doctor', isEqualTo: doctorName);

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: query.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading patients: ${snapshot.error}'));
            }

            final docs = snapshot.data?.docs ?? [];
            print('DoctorPatientsTab -> appointments count = ${docs.length}');
            if (docs.isEmpty) {
              return const Center(child: Text('No patients found for this doctor yet.'));
            }

            final Map<String, _DoctorPatientSummary> patients = {};
            for (final doc in docs) {
              final data = doc.data();

              final userId = (data['userId'] ?? '').toString().trim();
              if (userId.isEmpty) continue;

              String patientName = (data['patientName'] ?? '').toString().trim();
              String patientEmail = (data['patientEmail'] ?? '').toString().trim();
              if (patientEmail.isEmpty && data['email'] != null) {
                patientEmail = data['email'].toString();
              }

              final status = (data['status'] ?? 'Pending').toString();
              final date = _parseDate(data['date']);

              patients.update(
                userId,
                (old) => old.copyWith(
                  visitsCount: old.visitsCount + 1,
                  lastStatus: status,
                  lastVisit: _maxDate(old.lastVisit, date),
                ),
                ifAbsent: () => _DoctorPatientSummary(
                  userId: userId,
                  name: patientName,
                  email: patientEmail,
                  visitsCount: 1,
                  lastStatus: status,
                  lastVisit: date,
                ),
              );
            }

            final items = patients.values.toList()
              ..sort((a, b) {
                final da = a.lastVisit ?? DateTime.fromMillisecondsSinceEpoch(0);
                final db = b.lastVisit ?? DateTime.fromMillisecondsSinceEpoch(0);
                return db.compareTo(da);
              });

            print('DoctorPatientsTab -> unique patients = ${items.length}');

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final p = items[index];
                final needsLookup = p.name.trim().isEmpty || p.name.toLowerCase().contains('unknown patient');

                  return FutureBuilder<String>(
                  future: needsLookup ? _getPatientDisplayName(p.userId, fallback: p.email) : Future.value(p.name),
                  builder: (context, snapshotName) {
                    final displayName = snapshotName.data ?? (p.name.isEmpty ? 'Patient' : p.name);
                    final initials = _initialsFromName(displayName);
                    final lastVisitText = _formatDate(p.lastVisit);
                    final isDark = Theme.of(context).brightness == Brightness.dark;

           return TweenAnimationBuilder(
  duration: const Duration(milliseconds: 180),
  tween: Tween<double>(begin: 1, end: 1),
  builder: (context, scale, child) {
    return Transform.scale(
      scale: scale,
      child: GestureDetector(
        onTapDown: (_) {
          // ضغط ↓ يصغر الكرت شوي
          (context as Element).markNeedsBuild();
        },
        onTapUp: (_) async {
          await Future.delayed(const Duration(milliseconds: 120));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorPatientDetailsScreen(
                userId: p.userId,
                displayName: displayName,
                email: p.email,
                doctorName: doctorName,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: isDark
                    ? Colors.white.withOpacity(.05)
                    : Colors.white.withOpacity(.45),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(.08)
                      : Colors.white.withOpacity(.55),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.15),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          kPrimaryColor.withOpacity(.7),
                          kPrimaryColor.withOpacity(.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (p.email.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            p.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          "Visits: ${p.visitsCount} • Last: $lastVisitText",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: _statusColor(p.lastStatus).withOpacity(.15),
                      border: Border.all(color: _statusColor(p.lastStatus)),
                    ),
                    child: Text(
                      p.lastStatus,
                      style: TextStyle(
                        color: _statusColor(p.lastStatus),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  },
);
 
                    },
                  );
              },
            );
          },
        );
      }

    );

  }

  Future<String> _getPatientDisplayName(String userId, {String fallback = 'Patient'}) async {
    if (userId.isEmpty) return fallback.isNotEmpty ? fallback : 'Patient';
    try {
      final snap = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final data = snap.data();
      final fullName = data?['fullName']?.toString().trim();
      if (fullName != null && fullName.isNotEmpty) return fullName;
    } catch (_) {}
    return fallback.isNotEmpty ? fallback : 'Patient';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _initialsFromName(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    final first = parts.first.characters.first.toUpperCase();
    final last = parts.last.characters.first.toUpperCase();
    return '$first$last';
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'canceled':
      case 'cancelled':
        color = Colors.red;
        break;
      case 'rescheduled':
        color = Colors.orange;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  DateTime? _maxDate(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) {
      try {
        return DateFormat('MMMM d, yyyy').parse(raw);
      } catch (_) {
        try {
          return DateFormat('MMMM d yyyy').parse(raw.replaceAll(',', ''));
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'canceled':
      case 'cancelled':
        return Colors.red;
      case 'rescheduled':
        return Colors.orange;
      default:
        return Colors.orange;
    }
  }
}

// موديل مختصر لتلخيص المريض
class _DoctorPatientSummary {
  final String userId;
  final String name;
  final String email;
  final int visitsCount;
  final String lastStatus;
  final DateTime? lastVisit;

  _DoctorPatientSummary({
    required this.userId,
    required this.name,
    required this.email,
    required this.visitsCount,
    required this.lastStatus,
    required this.lastVisit,
  });

  _DoctorPatientSummary copyWith({
    String? name,
    String? email,
    int? visitsCount,
    String? lastStatus,
    DateTime? lastVisit,
  }) {
    return _DoctorPatientSummary(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      visitsCount: visitsCount ?? this.visitsCount,
      lastStatus: lastStatus ?? this.lastStatus,
      lastVisit: lastVisit ?? this.lastVisit,
    );
  }
}



/// ============================/// ============================
/// 4) تبويب إعدادات الطبيب
/// ============================
class _DoctorSettingsTab extends StatefulWidget {
  const _DoctorSettingsTab();

  @override
  State<_DoctorSettingsTab> createState() => _DoctorSettingsTabState();
}

class _DoctorSettingsTabState extends State<_DoctorSettingsTab> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    // TODO: لو حابب تجيب حالة الإشعارات من Firestore أو SharedPreferences
  }

  Future<void> _openEditProfile() async {
    await Navigator.pushNamed(context, '/doctor-edit-profile');
  }

  void _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });

    // TODO: خزّن القيمة في Firestore أو SharedPreferences
    // مثال:
    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   await FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(user.uid)
    //       .update({'notificationsEnabled': value});
    // }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withOpacity(isDark ? 0.18 : 0.10),
            Theme.of(context).scaffoldBackgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          _buildProfileHeader(),
          const SizedBox(height: 24),

          const Text(
            'General',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Edit profile
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit profile',
            subtitle: 'Update your personal information',
            onTap: _openEditProfile,
          ),

          // Notifications
          _SettingsSwitchTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Appointment reminders & updates',
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),

          const SizedBox(height: 24),
          const Text(
            'App',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Theme tile -> use ThemeProvider
          _SettingsSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Theme',
            subtitle: isDark ? 'Dark mode' : 'Light mode',
            value: isDark,
            onChanged: (value) {
              final themeProvider =
                  Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.toggleTheme(value);
            },
          ),

          // Language tile (placeholder)
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English / العربية (soon)',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Language switching will be available soon.'),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                'Log out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

Widget _buildProfileHeader() {
  final user = FirebaseAuth.instance.currentUser;

  return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    future: FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get(),
    builder: (context, snapshot) {
      String fullName = user?.email ?? 'Doctor';
      String role = 'Doctor';

      if (snapshot.hasData && snapshot.data!.data() != null) {
        final data = snapshot.data!.data()!;
        fullName = (data['fullName'] ?? fullName).toString();
        role = (data['role'] ?? role).toString();
      }

      final isDark = Theme.of(context).brightness == Brightness.dark;

      return ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color: isDark
                  ? Colors.white.withOpacity(.05)
                  : Colors.white.withOpacity(.35),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(.07)
                    : Colors.white.withOpacity(.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.35)
                      : Colors.blue.withOpacity(.18),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              children: [
                // Avatar glass circle
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? Colors.white.withOpacity(.06)
                            : Colors.white.withOpacity(.55),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(.25),
                            blurRadius: 14,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 34,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

}

/// بلاطات إعدادات عادية
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: kPrimaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

/// بلاطة فيها سويتش
class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: kPrimaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Switch(
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: kPrimaryColor,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
