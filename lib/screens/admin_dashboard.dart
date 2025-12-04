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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pages = [
      const _OverviewTab(),       // NEW
      const _AppointmentsTab(),
      const _PatientsTab(),
      const _DoctorsTab(),
      const _AdminSettingsTab(),
    ];

    final pageTitles = [
      'Overview',                // NEW
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
            icon: Icon(Icons.dashboard_customize_outlined),
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

//
// =======================
// 0) تبويب الـ OVERVIEW (Dashboard)
// =======================
//

class _OverviewTab extends StatefulWidget {
  const _OverviewTab({super.key});

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  Future<Map<String, dynamic>> _loadStats() async {
    final firestore = FirebaseFirestore.instance;

    final apptSnap = await firestore.collection('appointments').get();
    final patientsSnap = await firestore
        .collection('users')
        .where('role', isEqualTo: 'Patient')
        .get();
    final doctorsSnap = await firestore.collection('doctors').get();

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfToday.subtract(const Duration(days: 7));

    int totalAppts = 0;
    int todayAppts = 0;
    int weekAppts = 0;
    int pending = 0;
    int approved = 0;
    int canceled = 0;

    final Map<String, int> doctorCounts = {};

    for (final doc in apptSnap.docs) {
      totalAppts++;
      final data = doc.data();

      final status =
          (data['status'] ?? '').toString().toLowerCase().trim();
      if (status == 'pending') pending++;
      if (status == 'approved') approved++;
      if (status == 'canceled' || status == 'cancelled') canceled++;

      final doctorName = (data['doctor'] ?? '').toString();
      if (doctorName.isNotEmpty) {
        doctorCounts[doctorName] = (doctorCounts[doctorName] ?? 0) + 1;
      }

      final createdAt = data['createdAt'];
      if (createdAt is Timestamp) {
        final dt = createdAt.toDate();
        if (!dt.isBefore(startOfToday) &&
            dt.isBefore(startOfToday.add(const Duration(days: 1)))) {
          todayAppts++;
        }
        if (!dt.isBefore(startOfWeek)) {
          weekAppts++;
        }
      }
    }

    final topDoctors = doctorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3Doctors = topDoctors.take(3).toList();

    return {
      'totalAppointments': totalAppts,
      'todayAppointments': todayAppts,
      'weekAppointments': weekAppts,
      'pendingAppointments': pending,
      'approvedAppointments': approved,
      'canceledAppointments': canceled,
      'totalPatients': patientsSnap.docs.length,
      'totalDoctors': doctorsSnap.docs.length,
      'topDoctors': top3Doctors,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading stats: ${snapshot.error}'),
          );
        }

        final data = snapshot.data ?? {};
        final totalAppts = data['totalAppointments'] ?? 0;
        final todayAppts = data['todayAppointments'] ?? 0;
        final weekAppts = data['weekAppointments'] ?? 0;
        final pending = data['pendingAppointments'] ?? 0;
        final approved = data['approvedAppointments'] ?? 0;
        final canceled = data['canceledAppointments'] ?? 0;
        final totalPatients = data['totalPatients'] ?? 0;
        final totalDoctors = data['totalDoctors'] ?? 0;
        final List<MapEntry<String, int>> topDoctors =
            (data['topDoctors'] as List<MapEntry<String, int>>?) ?? [];

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                kPrimaryColor.withOpacity(isDark ? 0.14 : 0.08),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====== Card كبيرة في الأعلى ======
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        kPrimaryColor,
                        kPrimaryColor.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Today\'s Overview',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$todayAppts appointments today • $pending pending',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$totalAppts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$weekAppts last 7 days',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ====== إحصائيات سريعة على شكل Grid ======
                Text(
                  'Appointments Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatTile(
                        icon: Icons.hourglass_bottom_rounded,
                        label: 'Pending',
                        value: pending.toString(),
                        color: Colors.orange.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStatTile(
                        icon: Icons.check_circle_rounded,
                        label: 'Approved',
                        value: approved.toString(),
                        color: Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStatTile(
                        icon: Icons.cancel_rounded,
                        label: 'Canceled',
                        value: canceled.toString(),
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  'Clinic Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatTile(
                        icon: Icons.people_alt_rounded,
                        label: 'Patients',
                        value: totalPatients.toString(),
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStatTile(
                        icon: Icons.medical_information_rounded,
                        label: 'Doctors',
                        value: totalDoctors.toString(),
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Top Doctors',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                if (topDoctors.isEmpty)
                  const Text(
                    'No appointments yet.',
                    style: TextStyle(color: Colors.grey),
                  ),

                if (topDoctors.isNotEmpty)
                  Column(
                    children: topDoctors.map((entry) {
                      final name = entry.key;
                      final count = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.35)
                                  : Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.medical_services_rounded,
                                color: kPrimaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$count appointments',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                              ?.withOpacity(isDark ? 0.7 : 0.6) ??
                                          (isDark ? Colors.white70 : Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// بلاطة صغيرة للإحصائيات في الـ Overview
class _MiniStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.32)
                : Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? color.withOpacity(0.25) : color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDark ? color.withOpacity(0.9) : color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(isDark ? 0.75 : 0.6) ??
                      (isDark ? Colors.white70 : Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 1) تبويب المواعيد (Appointments) – تصميم حديث
/// =======================
class _AppointmentsTab extends StatefulWidget {
  const _AppointmentsTab({super.key});

  @override
  State<_AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<_AppointmentsTab> {
  final Query<Map<String, dynamic>> _query = FirebaseFirestore.instance
      .collection('appointments')
      .orderBy('createdAt', descending: true);

  String _statusFilter = 'All'; // All, Pending, Approved, Canceled

  Future<Map<String, dynamic>?> _getPatient(String uid) async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return snap.data();
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> ref,
    String newStatus,
  ) async {
    try {
      await ref.update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  Future<void> _deleteAppointment(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      await ref.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withOpacity(isDark ? 0.12 : 0.06),
            theme.scaffoldBackgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _query.snapshots(),
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

          final allDocs = snapshot.data?.docs ?? [];

          if (allDocs.isEmpty) {
            return const Center(
              child: Text('No appointments found.'),
            );
          }

          // إحصائيات عامة
          int total = allDocs.length;
          int pending = 0;
          int approved = 0;
          int canceled = 0;

          for (final d in allDocs) {
            final s = (d.data()['status'] ?? '').toString().toLowerCase();
            if (s == 'pending') pending++;
            if (s == 'approved') approved++;
            if (s == 'canceled' || s == 'cancelled') canceled++;
          }

          // فلترة حسب الحالة
          final filteredDocs = allDocs.where((doc) {
            if (_statusFilter == 'All') return true;
            final s =
                (doc.data()['status'] ?? '').toString().toLowerCase().trim();
            return s == _statusFilter.toLowerCase();
          }).toList();

          return Column(
            children: [
              const SizedBox(height: 8),
              // Row الإحصائيات بالأعلى
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatCard(label: 'Total', value: total.toString()),
                    _StatCard(label: 'Pending', value: pending.toString()),
                    _StatCard(label: 'Approved', value: approved.toString()),
                    _StatCard(label: 'Canceled', value: canceled.toString()),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // فلاتر الحالة
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    _buildFilterChip('Pending'),
                    _buildFilterChip('Approved'),
                    _buildFilterChip('Canceled'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              // قائمة المواعيد
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filteredDocs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data();
                    final ref = doc.reference;

                    final doctor =
                        (data['doctor'] ?? 'Unknown doctor').toString();
                    final service =
                        (data['serviceName'] ?? 'Unknown service').toString();
                    final duration = (data['duration'] ?? '').toString();
                    final price = (data['price'] ?? '').toString();
                    final status =
                        (data['status'] ?? 'Pending').toString().trim();
                    final dateStr = (data['date'] ?? '').toString();
                    final timeStr = (data['time'] ?? '').toString();
                    final userId = (data['userId'] ?? '').toString();

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _getPatient(userId),
                      builder: (context, patientSnap) {
                        String patientName = 'Unknown patient';
                        String patientEmail = '';

                        if (patientSnap.hasData && patientSnap.data != null) {
                          patientName =
                              (patientSnap.data!['fullName'] ?? 'Unknown')
                                  .toString();
                          patientEmail =
                              (patientSnap.data!['email'] ?? '').toString();
                        }

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.35)
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // الصف العلوي: اسم المريض + badge الحالة + menu
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          kPrimaryColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.event_note_rounded,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          patientName,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (patientEmail.isNotEmpty)
                                          Text(
                                            patientEmail,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.textTheme.bodySmall?.color
                                                      ?.withOpacity(isDark ? 0.75 : 0.6) ??
                                                  (isDark ? Colors.white70 : Colors.grey),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _StatusBadge(status: status),
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'approve') {
                                            _updateStatus(
                                                context, ref, 'Approved');
                                          } else if (value == 'cancel') {
                                            _updateStatus(
                                                context, ref, 'Canceled');
                                          } else if (value == 'pending') {
                                            _updateStatus(
                                                context, ref, 'Pending');
                                          } else if (value == 'delete') {
                                            _deleteAppointment(
                                                context, ref);
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'approve',
                                            child:
                                                Text('Mark as Approved'),
                                          ),
                                          PopupMenuItem(
                                            value: 'cancel',
                                            child:
                                                Text('Mark as Canceled'),
                                          ),
                                          PopupMenuItem(
                                            value: 'pending',
                                            child:
                                                Text('Mark as Pending'),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // معلومات الموعد
                              Row(
                                children: [
                                  const Icon(Icons.medical_services_rounded,
                                      size: 18, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '$doctor • $service',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (duration.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.schedule_rounded,
                                        size: 18, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      duration,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    dateStr,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.access_time_rounded,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeStr,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              if (price.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.monetization_on_rounded,
                                        size: 18, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      '\$$price',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final theme = Theme.of(context);
    final bool selected = _statusFilter == label;
    final bool isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: kPrimaryColor.withOpacity(isDark ? 0.28 : 0.18),
        backgroundColor: theme.cardColor,
        labelStyle: TextStyle(
          color: selected
              ? kPrimaryColor
              : theme.textTheme.bodySmall?.color ?? Colors.grey[700],
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 12,
        ),
        onSelected: (_) {
          setState(() {
            _statusFilter = label;
          });
        },
      ),
    );
  }
}

/// Badge صغيرة ملوّنة حسب حالة الموعد
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final lower = status.toLowerCase();
    Color bg;
    Color fg;
    String text = status;

    if (lower == 'approved') {
      bg = isDark ? Colors.green.withOpacity(0.25) : Colors.green.shade50;
      fg = isDark ? Colors.greenAccent.shade200 : Colors.green.shade700;
    } else if (lower == 'canceled' || lower == 'cancelled') {
      bg = isDark ? Colors.red.withOpacity(0.25) : Colors.red.shade50;
      fg = isDark ? Colors.redAccent.shade200 : Colors.red.shade700;
    } else {
      bg = isDark ? Colors.orange.withOpacity(0.25) : Colors.orange.shade50;
      fg = isDark ? Colors.orangeAccent.shade200 : Colors.orange.shade700;
      if (lower.isEmpty) text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Card صغيرة للإحصائيات
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseText =
        theme.textTheme.bodySmall?.color ?? (isDark ? Colors.white70 : Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.32)
                : Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : kPrimaryColor,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: baseText,
            ),
          ),
        ],
      ),
    );
  }
}

//
// =======================
// 2) تبويب المرضى
// =======================
//
//
// =======================
// 2) تبويب المرضى (Patients) – تصميم حديث
// =======================
//

class _PatientsTab extends StatelessWidget {
  const _PatientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final query = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Patient')
        .orderBy('fullName', descending: false);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withOpacity(0.06),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
              child: Text('No patients found.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final name = (data['fullName'] ?? 'Unknown').toString();
              final email = (data['email'] ?? '').toString();
              final phone = (data['phoneNumber'] ?? '').toString();

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.32)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (email.isNotEmpty)
                            Text(
                              email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(isDark ? 0.75 : 0.6) ??
                                    (isDark ? Colors.white70 : Colors.grey),
                              ),
                            ),
                          if (phone.isNotEmpty)
                            Text(
                              'Phone: $phone',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(isDark ? 0.75 : 0.6) ??
                                    (isDark ? Colors.white70 : Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

//
// =======================
// 3) تبويب الأطباء
// =======================


//
// =======================
// 3) تبويب الأطباء (Doctors) – تصميم حديث
// =======================
//

class _DoctorsTab extends StatefulWidget {
  const _DoctorsTab({super.key});

  @override
  State<_DoctorsTab> createState() => _DoctorsTabState();
}

class _DoctorsTabState extends State<_DoctorsTab> {
  final CollectionReference<Map<String, dynamic>> _doctorsRef =
      FirebaseFirestore.instance.collection('doctors');

  Future<void> _showDoctorDialog(
      {DocumentSnapshot<Map<String, dynamic>>? doc}) async {
    final isEdit = doc != null;
    final data = doc?.data() ?? {};

    final TextEditingController nameController =
        TextEditingController(text: data['name']?.toString() ?? '');
    final TextEditingController specialtyController =
        TextEditingController(text: data['specialty']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.medical_services_rounded,
                          color: kPrimaryColor),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEdit ? 'Edit Doctor' : 'Add Doctor',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: specialtyController,
                  decoration: const InputDecoration(
                    labelText: 'Specialty',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final specialty = specialtyController.text.trim();

                        if (name.isEmpty || specialty.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill all fields')),
                          );
                          return;
                        }

                        try {
                          if (isEdit) {
                            await doc!.reference.update({
                              'name': name,
                              'specialty': specialty,
                            });
                          } else {
                            await _doctorsRef.add({
                              'name': name,
                              'specialty': specialty,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                          }

                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to save doctor: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isEdit ? 'Save' : 'Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteDoctor(DocumentReference ref) async {
    try {
      await ref.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete doctor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withOpacity(0.06),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _doctorsRef.orderBy('name').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading doctors: ${snapshot.error}'),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Center(
                child: Text('No doctors found. Tap + to add one.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();
                final name = (data['name'] ?? 'Unknown doctor').toString();
                final specialty =
                    (data['specialty'] ?? 'Unknown specialty').toString();

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.32)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              specialty,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(isDark ? 0.75 : 0.6) ??
                                    (isDark ? Colors.white70 : Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showDoctorDialog(doc: doc);
                          } else if (value == 'delete') {
                            _deleteDoctor(doc.reference);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showDoctorDialog(),
          backgroundColor: kPrimaryColor,
          icon: const Icon(Icons.add),
          label: const Text('Add Doctor'),
        ),
      ),
    );
  }
}

//
// =======================
// 4) تبويب إعدادات الأدمن
// =======================
////
// =======================
// 4) تبويب إعدادات الأدمن – تصميم أفضل
// =======================
//

class _AdminSettingsTab extends StatelessWidget {
  const _AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withOpacity(0.06),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.32)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '-',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(isDark ? 0.75 : 0.6) ??
                                (isDark ? Colors.white70 : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
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
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              },
              icon: const Icon(Icons.phone_iphone),
              label: const Text('Open Patient App View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kPrimaryColor,
                side: BorderSide(color: kPrimaryColor.withOpacity(0.4)),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
