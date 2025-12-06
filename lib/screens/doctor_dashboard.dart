import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:characters/characters.dart';

import '../constants.dart';

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
  const _DoctorOverviewTab({super.key});

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
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: kPrimaryColor),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      )

    );
  }
}

class _MiniBarChart extends StatelessWidget {
  final DateTime startDate; // أول يوم (من آخر ٧ أيام)
  final Map<String, int> dailyCounts;

  const _MiniBarChart({
    super.key,
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
  const _DoctorAppointmentsTab({super.key});

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
  const _DoctorPatientsTab({super.key});

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
    // debug: print('DoctorPatientsTab -> fullName from users = $name');
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
        // debug: print('DoctorPatientsTab -> using doctor = $doctorName');

        final query = FirebaseFirestore.instance
            .collection('appointments')
            .where('doctor', isEqualTo: doctorName);

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
                child: Text('Error loading patients: ${snapshot.error}'),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(
                child: Text('No patients found for this doctor yet.'),
              );
            }

            // تجميع حسب userId
            final Map<String, _DoctorPatientSummary> patients = {};

            for (final doc in docs) {
              final data = doc.data();
              final userId = (data['userId'] ?? '') as String;
              if (userId.isEmpty) continue;

              final patientName =
                  (data['patientName'] ?? 'Unknown patient').toString();
              final patientEmail = (data['patientEmail'] ?? '').toString();
              final status = (data['status'] ?? 'Pending').toString();

              DateTime? date;
              final rawDate = data['date'];
              if (rawDate is Timestamp) {
                date = rawDate.toDate();
              } else if (rawDate is String) {
                // currently ignore parsing string dates here
                date = null;
              }

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

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final p = items[index];

                final lastVisitText = p.lastVisit == null
                    ? 'No visits date'
                    : '${p.lastVisit!.year}-${p.lastVisit!.month.toString().padLeft(2, '0')}-${p.lastVisit!.day.toString().padLeft(2, '0')}';

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
                          shape: BoxShape.circle,
                          color: kPrimaryColor.withOpacity(0.12),
                        ),
                        child: Center(
                          child: Text(
                            _initialsFromName(p.name),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (p.email.isNotEmpty) ...[
                              const SizedBox(height: 2),
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
                              'Visits: ${p.visitsCount} • Last visit: $lastVisitText',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _statusBadge(p.lastStatus),
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

  // باقي الميثودز كما هي
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

  String _initialsFromName(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    final first = parts.first.characters.first.toUpperCase();
    final last = parts.last.characters.first.toUpperCase();
    return '$first$last';
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


/// ============================
/// 4) تبويب إعدادات الطبيب
/// ============================
class _DoctorSettingsTab extends StatelessWidget {
  const _DoctorSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Doctor Settings\n(Profile, notifications, preferences)',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

