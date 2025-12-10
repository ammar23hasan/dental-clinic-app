import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';

class DoctorPatientDetailsScreen extends StatelessWidget {
  final String userId;
  final String displayName;
  final String email;
  final String doctorName;

  const DoctorPatientDetailsScreen({
    super.key,
    required this.userId,
    required this.displayName,
    required this.email,
    required this.doctorName,
  });

  // ✅ دالة توليد تقرير PDF مع فلتر حالة اختياري + QR
  Future<void> _generatePdfReport(
    BuildContext context, {
    required String patientName,
    required String email,
    required String doctorName,
    required int totalVisits,
    required int pending,
    required int approved,
    required int canceled,
    required double totalSpent,
    required String lastVisitText,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> visits,

    /// مثلاً: null = الكل, 'approved' فقط الموافق عليها
    String? statusFilter,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // ✅ فلترة الزيارات داخل التقرير (حسب الحالة لو موجودة)
    final filteredVisits = statusFilter == null
        ? visits
        : visits.where((doc) {
            final data = doc.data();
            final status =
                (data['status'] ?? '').toString().toLowerCase().trim();
            return status == statusFilter.toLowerCase().trim();
          }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
        ),
        build: (pw.Context ctx) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ✅ هيدر + QR code
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Patient Report',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Generated on: ${DateFormat.yMMMd().add_Hm().format(now)}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        if (statusFilter != null) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Filter: ${statusFilter.toUpperCase()}',
                            style: const pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data:
                          'patient:$patientName;doctor:$doctorName;email:$email;generated:${now.toIso8601String()}',
                      width: 70,
                      height: 70,
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),

                // معلومات المريض
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        patientName,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          email,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Doctor: $doctorName',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 16),

                // إحصائيات سريعة
                pw.Text(
                  'Overview',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Bullet(
                    text: 'Total visits: $totalVisits',
                    style: const pw.TextStyle(fontSize: 11)),
                pw.Bullet(
                    text: 'Approved visits: $approved',
                    style: const pw.TextStyle(fontSize: 11)),
                pw.Bullet(
                    text: 'Pending visits: $pending',
                    style: const pw.TextStyle(fontSize: 11)),
                pw.Bullet(
                    text: 'Canceled visits: $canceled',
                    style: const pw.TextStyle(fontSize: 11)),
                pw.Bullet(
                    text: 'Total spent: \$${totalSpent.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 11)),
                pw.Bullet(
                    text: 'Last visit: $lastVisitText',
                    style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 16),

                // جدول الزيارات
                pw.Text(
                  statusFilter == null
                      ? 'Visit history'
                      : 'Visit history (${statusFilter.toUpperCase()} only)',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),

                if (filteredVisits.isEmpty)
                  pw.Text(
                    'No visits found for this patient.',
                    style: pw.TextStyle(fontSize: 11),
                  )
                else
                  pw.Table.fromTextArray(
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    headerStyle: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    cellAlignment: pw.Alignment.centerLeft,
                    headers: [
                      'Service',
                      'Status',
                      'Date',
                      'Time',
                      'Duration',
                      'Price',
                    ],
                    data: filteredVisits.map((doc) {
                      final data = doc.data();
                      final service =
                          (data['serviceName'] ?? '').toString();
                      final status =
                          (data['status'] ?? '').toString();
                      final dateStr =
                          (data['date'] ?? '').toString();
                      final timeStr =
                          (data['time'] ?? '').toString();
                      final duration =
                          (data['duration'] ?? '').toString();
                      final price =
                          (data['price'] ?? '').toString();

                      return [
                        service,
                        status,
                        dateStr,
                        timeStr,
                        duration,
                        price.isEmpty ? '-' : '\$$price',
                      ];
                    }).toList(),
                  ),
              ],
            ),
          ];
        },
      ),
    );

    // عرض واجهة الطباعة / المشاركة
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  // ✅ BottomSheet لاختيار نوع التقرير (فلتر الحالة)
  Future<void> _openExportOptions(
    BuildContext context, {
    required String patientName,
    required String email,
    required String doctorName,
    required int totalVisits,
    required int pending,
    required int approved,
    required int canceled,
    required double totalSpent,
    required String lastVisitText,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> visits,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetCtx) {
        Widget _buildTile({
          required String title,
          String? subtitle,
          required IconData icon,
          String? statusFilter,
        }) {
          return ListTile(
            leading: Icon(icon, color: kPrimaryColor),
            title: Text(title),
            subtitle: subtitle == null ? null : Text(subtitle),
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              await _generatePdfReport(
                context,
                patientName: patientName,
                email: email,
                doctorName: doctorName,
                totalVisits: totalVisits,
                pending: pending,
                approved: approved,
                canceled: canceled,
                totalSpent: totalSpent,
                lastVisitText: lastVisitText,
                visits: visits,
                statusFilter: statusFilter,
              );
            },
          );
        }

        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Text(
                  'Export PDF report',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose which visits to include in the report',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                _buildTile(
                  title: 'All visits',
                  subtitle: 'Include all visits for this patient',
                  icon: Icons.all_inclusive_rounded,
                  statusFilter: null,
                ),
                _buildTile(
                  title: 'Approved only',
                  subtitle: 'Include only approved visits',
                  icon: Icons.check_circle_outline,
                  statusFilter: 'approved',
                ),
                _buildTile(
                  title: 'Pending only',
                  subtitle: 'Include only pending visits',
                  icon: Icons.hourglass_bottom_rounded,
                  statusFilter: 'pending',
                ),
                _buildTile(
                  title: 'Canceled only',
                  subtitle: 'Include only canceled visits',
                  icon: Icons.cancel_outlined,
                  statusFilter: 'canceled',
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Query<Map<String, dynamic>> _appointmentsQuery() {
    // كل المواعيد لهذا المريض مع هذا الدكتور
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .where('doctor', isEqualTo: doctorName);
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String && raw.isNotEmpty) {
      try {
        // مثال: December 27, 2025
        return DateFormat('MMMM d, yyyy').parse(raw);
      } catch (_) {
        try {
          return DateFormat('MMMM d yyyy')
              .parse(raw.replaceAll(',', ''));
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          // ✅ زر PDF في الـ AppBar يفتح الـ BottomSheet للفلتر
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _appointmentsQuery().snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];

              // نحسب الإحصائيات هنا عالسريع (لو بدك بس لما يكون في داتا)
              int totalVisits = docs.length;
              int pending = 0;
              int approved = 0;
              int canceled = 0;
              double totalSpent = 0;
              DateTime? lastVisit;

              for (final d in docs) {
                final data = d.data();
                final status = (data['status'] ?? '')
                    .toString()
                    .toLowerCase()
                    .trim();

                if (status == 'pending') pending++;
                if (status == 'approved') approved++;
                if (status == 'canceled' || status == 'cancelled') {
                  canceled++;
                }

                final price = double.tryParse(
                        (data['price'] ?? '').toString()) ??
                    0;
                totalSpent += price;

                final dt = _parseDate(data['date']);
                if (dt != null) {
                  if (lastVisit == null || dt.isAfter(lastVisit!)) {
                    lastVisit = dt;
                  }
                }
              }

              String lastVisitText = lastVisit == null
                  ? 'No visits date'
                  : DateFormat.yMMMd().format(lastVisit!);

              return IconButton(
                tooltip: 'Export PDF report',
                onPressed: docs.isEmpty
                    ? null
                    : () {
                        _openExportOptions(
                          context,
                          patientName: displayName,
                          email: email,
                          doctorName: doctorName,
                          totalVisits: totalVisits,
                          pending: pending,
                          approved: approved,
                          canceled: canceled,
                          totalSpent: totalSpent,
                          lastVisitText: lastVisitText,
                          visits: docs,
                        );
                      },
                icon: const Icon(Icons.picture_as_pdf_rounded),
              );
            },
          ),
        ],
      ),
      body: Container(
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
          stream: _appointmentsQuery().snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child:
                    Text('Error loading visits: ${snapshot.error}'),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            // ===== حساب إحصائيات المريض =====
            int totalVisits = docs.length;
            int pending = 0;
            int approved = 0;
            int canceled = 0;
            double totalSpent = 0;
            DateTime? lastVisit;

            // توزيع الخدمات
            final Map<String, int> serviceCounter = {};

            // الموعد القادم
            final now = DateTime.now();
            DateTime? nextVisit;
            String nextService = '';
            String nextStatus = '';
            String nextDateStr = '';
            String nextTimeStr = '';

            for (final d in docs) {
              final data = d.data();
              final status = (data['status'] ?? '')
                  .toString()
                  .toLowerCase()
                  .trim();
              final serviceName =
                  (data['serviceName'] ?? 'Unknown service')
                      .toString();

              if (status == 'pending') pending++;
              if (status == 'approved') approved++;
              if (status == 'canceled' || status == 'cancelled') {
                canceled++;
              }

              final price = double.tryParse(
                      (data['price'] ?? '').toString()) ??
                  0;
              totalSpent += price;

              final dt = _parseDate(data['date']);
              if (dt != null) {
                // آخر زيارة
                if (lastVisit == null || dt.isAfter(lastVisit!)) {
                  lastVisit = dt;
                }

                // الموعد القادم (أقرب موعد من الآن - غير ملغى)
                final isCanceled = status.contains('cancel');
                if (!isCanceled &&
                    (dt.isAfter(now) ||
                        dt.isAtSameMomentAs(now))) {
                  if (nextVisit == null ||
                      dt.isBefore(nextVisit!)) {
                    nextVisit = dt;
                    nextService = serviceName;
                    nextStatus =
                        (data['status'] ?? 'Pending').toString();
                    nextDateStr =
                        (data['date'] ?? '').toString();
                    nextTimeStr =
                        (data['time'] ?? '').toString();
                  }
                }
              }

              // تجميع الخدمات
              serviceCounter[serviceName] =
                  (serviceCounter[serviceName] ?? 0) + 1;
            }

            String lastVisitText = lastVisit == null
                ? 'No visits date'
                : DateFormat.yMMMd().format(lastVisit!);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ========== كرت الهيدر (الاسم + الايميل) ==========
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        kPrimaryColor,
                        kPrimaryColor.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.30),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        displayName.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        'Patient of $doctorName',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ========== إحصائيات سريعة ==========
                Row(
                  children: [
                    Expanded(
                      child: _PatientStatChip(
                        label: 'Total visits',
                        value: totalVisits.toString(),
                        icon: Icons.event_available_outlined,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PatientStatChip(
                        label: 'Approved',
                        value: approved.toString(),
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _PatientStatChip(
                        label: 'Pending',
                        value: pending.toString(),
                        icon: Icons.hourglass_bottom_rounded,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PatientStatChip(
                        label: 'Canceled',
                        value: canceled.toString(),
                        icon: Icons.cancel_outlined,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _PatientStatChip(
                        label: 'Total spent',
                        value:
                            '\$${totalSpent.toStringAsFixed(2)}',
                        icon: Icons.payments_outlined,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PatientStatChip(
                        label: 'Last visit',
                        value: lastVisitText,
                        icon: Icons.calendar_today_outlined,
                        color: Colors.indigo,
                        isSmallText: true,
                      ),
                    ),
                  ],
                ),

                // ========== الموعد القادم ==========
                if (nextVisit != null) ...[
                  const SizedBox(height: 18),
                  _UpcomingVisitCard(
                    service: nextService,
                    status: nextStatus,
                    dateStr: nextDateStr,
                    timeStr: nextTimeStr,
                  ),
                ],

                // ========== توزيع الخدمات ==========
                if (serviceCounter.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _ServiceDistributionCard(
                      serviceCounter: serviceCounter),
                ],

                // ========== ملاحظات الطبيب ==========
                const SizedBox(height: 18),
                _PatientNotesSection(
                  userId: userId,
                  doctorName: doctorName,
                  patientName: displayName,
                ),

                const SizedBox(height: 24),

                Text(
                  'Visit history',
                  style:
                      theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                if (docs.isEmpty)
                  const Text(
                    'No visits found for this patient yet.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...docs.map((doc) {
                    final data = doc.data();
                    final service =
                        (data['serviceName'] ??
                                'Unknown service')
                            .toString();
                    final status =
                        (data['status'] ?? 'Pending')
                            .toString()
                            .trim();
                    final dateStr =
                        (data['date'] ?? '').toString();
                    final timeStr =
                        (data['time'] ?? '').toString();
                    final price =
                        (data['price'] ?? '').toString();
                    final duration =
                        (data['duration'] ?? '').toString();

                    return Container(
                      margin:
                          const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius:
                            BorderRadius.circular(16),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),
                              blurRadius: 6,
                              offset:
                                  const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration:
                                    BoxDecoration(
                                  color: kPrimaryColor
                                      .withOpacity(0.12),
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                ),
                                child: const Icon(
                                  Icons
                                      .event_note_rounded,
                                  color: kPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  service,
                                  style: theme.textTheme
                                      .titleMedium
                                      ?.copyWith(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                              _StatusPill(status: status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                  Icons
                                      .calendar_today_rounded,
                                  size: 16,
                                  color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                dateStr,
                                style:
                                    theme.textTheme
                                        .bodySmall,
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                  Icons
                                      .access_time_rounded,
                                  size: 16,
                                  color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                timeStr,
                                style:
                                    theme.textTheme
                                        .bodySmall,
                              ),
                            ],
                          ),
                          if (duration.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                    Icons
                                        .schedule_rounded,
                                    size: 16,
                                    color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  duration,
                                  style:
                                      theme.textTheme
                                          .bodySmall,
                                ),
                              ],
                            ),
                          ],
                          if (price.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons
                                      .monetization_on_rounded,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '\$$price',
                                  style:
                                      theme.textTheme
                                          .bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                // ✅ زر فخم لتصدير تقرير PDF مع فلتر
                _ExportPdfButton(
                  patientName: displayName,
                  onExport: () async {
                    if (docs.isEmpty) return;
                    await _openExportOptions(
                      context,
                      patientName: displayName,
                      email: email,
                      doctorName: doctorName,
                      totalVisits: totalVisits,
                      pending: pending,
                      approved: approved,
                      canceled: canceled,
                      totalSpent: totalSpent,
                      lastVisitText: lastVisitText,
                      visits: docs,
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PatientStatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isSmallText;

  const _PatientStatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isSmallText = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(isDark ? 0.30 : 0.26),
            color.withOpacity(isDark ? 0.18 : 0.16),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.30),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.06 : 0.75),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(isDark ? 0.14 : 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: Colors.black87),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmallText ? 13 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Colors.white.withOpacity(0.85),
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

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  Color _colorForStatus() {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'canceled':
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus();
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// كرت الموعد القادم
class _UpcomingVisitCard extends StatelessWidget {
  final String service;
  final String status;
  final String dateStr;
  final String timeStr;

  const _UpcomingVisitCard({
    required this.service,
    required this.status,
    required this.dateStr,
    required this.timeStr,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.cardColor,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(
          color: kPrimaryColor.withOpacity(0.4),
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.upcoming_rounded,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Next visit',
                  style:
                      theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  service,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style:
                          theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style:
                          theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusPill(status: status),
        ],
      ),
    );
  }
}

/// كرت توزيع الخدمات للمريض
class _ServiceDistributionCard extends StatelessWidget {
  final Map<String, int> serviceCounter;

  const _ServiceDistributionCard({
    required this.serviceCounter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = serviceCounter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = entries.first.value.toDouble();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Services breakdown',
            style: theme.textTheme.titleMedium
                ?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Most booked services for this patient',
            style: theme.textTheme.bodySmall
                ?.copyWith(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          ...entries.map((e) {
            final ratio = e.value / maxCount;
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: theme.textTheme
                          .bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    height: 8,
                    child: Stack(
                      children: [
                        Container(
                          decoration:
                              BoxDecoration(
                            color: kPrimaryColor
                                .withOpacity(0.10),
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        999),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor:
                              ratio.clamp(0.1, 1.0),
                          child: Container(
                            decoration:
                                BoxDecoration(
                              color: kPrimaryColor
                                  .withOpacity(
                                      0.85),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          999),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'x${e.value}',
                    style: theme.textTheme
                        .bodySmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// قسم ملاحظات الطبيب عن المريض
class _PatientNotesSection extends StatefulWidget {
  final String userId;
  final String doctorName;
  final String patientName;

  const _PatientNotesSection({
    required this.userId,
    required this.doctorName,
    required this.patientName,
  });

  @override
  State<_PatientNotesSection> createState() =>
      _PatientNotesSectionState();
}

class _PatientNotesSectionState
    extends State<_PatientNotesSection> {
  final TextEditingController _noteController =
      TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
         final doctorId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('doctor_patient_notes')
        .add({
      'userId': widget.userId,
      'doctorName': widget.doctorName,
      'patientName': widget.patientName,
      'note': _noteController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'doctorId': doctorId, // ✅ مهم
    });

      _noteController.clear();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to save note: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _openAddNoteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom:
                MediaQuery.of(ctx).viewInsets.bottom +
                    12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(
                    bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey
                      .withOpacity(0.4),
                  borderRadius:
                      BorderRadius.circular(999),
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Add note',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                        Icons.close_rounded),
                    onPressed: () =>
                        Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Write a note about the patient...',
                  filled: true,
                  fillColor: Theme.of(context)
                              .brightness ==
                          Brightness.dark
                      ? Colors.white
                          .withOpacity(0.05)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            14),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : _addNote,
                  style: ElevatedButton
                      .styleFrom(
                    backgroundColor:
                        kPrimaryColor,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 12,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              14),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.save_rounded),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : 'Save note',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

Stream<QuerySnapshot<Map<String, dynamic>>> _notesStream() {
  final doctorId = FirebaseAuth.instance.currentUser!.uid;

  return FirebaseFirestore.instance
      .collection('doctor_patient_notes')
      .where('userId', isEqualTo: widget.userId)
      .where('doctorId', isEqualTo: doctorId)
      .orderBy('createdAt', descending: true)
      .snapshots();
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.sticky_note_2_outlined,
                size: 20,
                color: kPrimaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Doctor notes',
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _openAddNoteSheet,
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add new note',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Private notes about this patient. Visible only to the doctor.',
              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<
              QuerySnapshot<
                  Map<String, dynamic>>>(
            stream: _notesStream(),
            builder:
                (context, snapshot) {
              if (snapshot
                      .connectionState ==
                  ConnectionState
                      .waiting) {
                return const Padding(
                  padding: EdgeInsets
                      .symmetric(
                          vertical: 12),
                  child: Center(
                    child:
                        CircularProgressIndicator(
                      color: kPrimaryColor,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 8,
                  ),
                  child: Text(
                    'Error loading notes: ${snapshot.error}',
                    style: const TextStyle(
                      color: Colors
                          .redAccent,
                    ),
                  ),
                );
              }

              final notesDocs =
                  snapshot.data?.docs ??
                      [];
              if (notesDocs.isEmpty) {
                return Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    top: 8,
                    bottom: 4,
                  ),
                  child: Text(
                    'No notes yet. Add the first note.',
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color:
                          Colors.grey,
                      fontStyle:
                          FontStyle
                              .italic,
                    ),
                  ),
                );
              }

              return Column(
                children: notesDocs
                    .map((doc) {
                  final data =
                      doc.data();
                  final noteText =
                      (data['note'] ?? '')
                          .toString()
                          .trim();
                  final ts =
                      data['createdAt'];
                  DateTime?
                      createdAt;
                  if (ts
                      is Timestamp) {
                    createdAt =
                        ts.toDate();
                  }
                  final createdText =
                      createdAt ==
                              null
                          ? ''
                          : DateFormat(
                                  'yMMMd • HH:mm')
                              .format(
                                  createdAt);

                  return _NoteCard(
                    text: noteText,
                    createdAtText:
                        createdText,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String text;
  final String createdAtText;

  const _NoteCard({
    required this.text,
    required this.createdAtText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.withOpacity(0.25),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (createdAtText.isNotEmpty) ...[
            Text(
              createdAtText,
              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            text,
            style: theme
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// زر فخم لتصدير تقرير PDF
class _ExportPdfButton extends StatelessWidget {
  final String patientName;
  final Future<void> Function() onExport;

  const _ExportPdfButton({
    required this.patientName,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onExport,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent.shade400,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 4,
      ),
      icon: const Icon(Icons.picture_as_pdf_rounded),
      label: Text(
        'Export PDF report for $patientName',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
