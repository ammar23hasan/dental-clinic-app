import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import 'main_screen.dart';
import 'login_screen.dart';
import '../main.dart';
import '../providers/theme_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 900; // same breakpoint as provided

    // pages for tabs
    final pages = const [
      _OverviewTab(),
      _AppointmentsTab(),
      _PatientsTab(),
      _DoctorsTab(),
      _AdminSettingsTab(),
    ];

    final pageTitles = [
      'Overview',
      'Appointments',
      'Patients',
      'Doctors',
      'Admin Settings',
    ];

    // Tablet layout: NavigationRail on the left
    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              extended: size.width >= 1150, // show labels on very wide screens
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedIconTheme: const IconThemeData(color: kPrimaryColor),
              selectedLabelTextStyle: const TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_customize_outlined),
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
                  icon: Icon(Icons.medical_services_outlined),
                  selectedIcon: Icon(Icons.medical_services),
                  label: Text('Doctors'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),

            // thin divider
            Container(
              width: 0.5,
              color: Colors.grey.withOpacity(0.3),
            ),

            // content area
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    pageTitles[_currentIndex],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: false,
                ),
                body: pages[_currentIndex],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout: bottom navigation bar
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
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
  const _OverviewTab();

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
                      final doctorName = entry.key;
                      final count = entry.value;

                      return FancyCard(
                        baseColor: kPrimaryColor,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.medical_services_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctorName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    '$count appointments',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.white70,
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
/// =======================
/// 1) تبويب المواعيد (Appointments) – مع زر Export PDF
/// =======================
class _AppointmentsTab extends StatefulWidget {
  const _AppointmentsTab();

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

  /// ====== NEW: توليد تقرير اليوم على شكل PDF ومشاركته ======
  Future<void> _exportTodayReportAsPdf(BuildContext context) async {
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = startOfToday.add(const Duration(days: 1));

      // نجيب مواعيد اليوم من Firestore باستخدام createdAt
      final snap = await FirebaseFirestore.instance
          .collection('appointments')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .where('createdAt',
              isLessThan: Timestamp.fromDate(endOfToday))
          .orderBy('createdAt')
          .get();

      if (snap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No appointments for today to export'),
          ),
        );
        return;
      }

      // نبني الـ PDF
      final pdf = pw.Document();
      final dateText =
          '${startOfToday.year}-${startOfToday.month.toString().padLeft(2, '0')}-${startOfToday.day.toString().padLeft(2, '0')}';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return [
              pw.Text(
                'Daily Appointments Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Date: $dateText',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: const [
                  'Time',
                  'Patient',
                  'Doctor',
                  'Service',
                  'Status',
                  'Price',
                ],
                data: snap.docs.map((doc) {
                  final data = doc.data();
                  final patientName =
                      (data['patientName'] ?? 'Unknown').toString();
                  final doctorName =
                      (data['doctor'] ?? 'Unknown').toString();
                  final service =
                      (data['serviceName'] ?? '-').toString();
                  final status =
                      (data['status'] ?? 'Pending').toString();
                  final time = (data['time'] ?? '-').toString();
                  final price = (data['price'] ?? '').toString();

                  return [
                    time,
                    patientName,
                    doctorName,
                    service,
                    status,
                    price.isNotEmpty ? '\$$price' : '',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE0E0E0),
                ),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(1.3),
                  5: const pw.FlexColumnWidth(1),
                },
              ),
            ];
          },
        ),
      );

      final bytes = await pdf.save();

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'daily_appointments_$dateText.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withOpacity(0.06),
            const Color.fromARGB(255, 255, 255, 255),
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
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total',
                        value: total.toString(),
                        icon: Icons.event_available,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Pending',
                        value: pending.toString(),
                        icon: Icons.hourglass_bottom_rounded,
                        color: Colors.orange.shade600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Approved',
                        value: approved.toString(),
                        icon: Icons.check_circle_rounded,
                        color: Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Canceled',
                        value: canceled.toString(),
                        icon: Icons.cancel_rounded,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // زر Export على يمين الفلاتر
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Text(
                      'Today\'s appointments report',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _exportTodayReportAsPdf(context),
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text(
                        'Export PDF',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
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
  color: Theme.of(context).cardColor,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    if (Theme.of(context).brightness == Brightness.light)
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
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
                                      color: kPrimaryColor.withOpacity(0.12),
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
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (patientEmail.isNotEmpty)
                                          Text(
                                            patientEmail,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
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
                                            _deleteAppointment(context, ref);
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'approve',
                                            child: Text('Mark as Approved'),
                                          ),
                                          PopupMenuItem(
                                            value: 'cancel',
                                            child: Text('Mark as Canceled'),
                                          ),
                                          PopupMenuItem(
                                            value: 'pending',
                                            child: Text('Mark as Pending'),
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
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  fontSize: 13,
),

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
                                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  fontSize: 13,
),

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
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  fontSize: 13,
),

                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.access_time_rounded,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeStr,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  fontSize: 13,
),

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
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  fontSize: 13,
),

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
    final bool selected = _statusFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: kPrimaryColor.withOpacity(0.18),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? kPrimaryColor : Colors.grey[700],
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

/// Badge widget for appointment status
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color _getColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'canceled':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Card صغيرة للإحصائيات
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(isDark ? 0.35 : 0.30),
            color.withOpacity(isDark ? 0.18 : 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.06 : 0.7),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.12 : 0.20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white : const Color.fromARGB(221, 255, 255, 255),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
              ],
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
  const _PatientsTab();

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

              return FancyCard(
                baseColor: kPrimaryColor,
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (email.isNotEmpty)
                            Text(
                              email,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          if (phone.isNotEmpty)
                            Text(
                              'Phone: $phone',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
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
  const _DoctorsTab();

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
                            await doc.reference.update({
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

                return FancyCard(
                  baseColor: kPrimaryColor,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              specialty,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
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
                        color: Colors.white,
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
            kPrimaryColor.withOpacity(isDark ? 0.12 : 0.06),
            theme.scaffoldBackgroundColor,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            color: theme.textTheme.bodySmall?.color?.withOpacity(
                                  isDark ? 0.75 : 0.6,
                                ) ??
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
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              activeColor: kPrimaryColor,
              title: const Text('Dark Mode'),
              subtitle: const Text(
                'Use dark theme for the admin panel and app',
                style: TextStyle(fontSize: 12),
              ),
              value: isDark,
              onChanged: (value) {
                final themeProvider =
                    Provider.of<ThemeProvider>(context, listen: false);
                themeProvider.toggleTheme(value);
              },
            ),
            const SizedBox(height: 16),
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

// FancyCard widget used above
class FancyCard extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const FancyCard({
    super.key,
    required this.child,
    required this.baseColor,
    this.padding = const EdgeInsets.all(14),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withOpacity(isDark ? 0.35 : 0.30),
            baseColor.withOpacity(isDark ? 0.18 : 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.06 : 0.7),
          width: 0.8,
        ),
      ),
      child: child,
    );
  }
}
