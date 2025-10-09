import 'package:flutter/material.dart';
import '../constants.dart'; // مسار ملف الثوابت

class AppointmentDetailsScreen extends StatelessWidget {
  const AppointmentDetailsScreen({super.key});

  // تم تحديث هذه الألوان لضمان استخدام الثوابت المعرفة
  final Color primaryColor = kPrimaryColor;
  final Color confirmedColor = kConfirmedColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Appointment Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // العودة للشاشة السابقة
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ********** 1. قسم الموعد الرئيسي (البطاقة الزرقاء) **********
              _buildMainAppointmentCard(),
              const SizedBox(height: 20),

              // ********** 2. قسم التفاصيل (Details) **********
              _buildDetailsCard(),
              const SizedBox(height: 20),

              // ********** 3. قسم التحضير (Preparation) **********
              _buildPreparationCard(),
              const SizedBox(height: 40),

              // ********** 4. قسم الإجراءات (Actions) **********
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // الدوال المساعدة (Helper Widgets)
  // -------------------------------------------------------------------

  // بناء بطاقة الموعد الرئيسية
  Widget _buildMainAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          const Text(
            'Regular Checkup',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Aug 15, 2025 at 10:00 AM',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          // زر الحالة (Confirmed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: confirmedColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'confirmed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء بطاقة التفاصيل
  Widget _buildDetailsCard() {
    return _CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          _buildDetailRow(
            icon: Icons.person_outline,
            title: 'Dr. Sarah Johnson',
            subtitle: 'Dentist',
          ),
          _buildDetailRow(
            icon: Icons.schedule,
            title: 'Duration',
            subtitle: '30 minutes',
          ),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            title: 'SmileCare Dental Clinic',
            subtitle: '123 Health Street, Medical District',
          ),
        ],
      ),
    );
  }

  // بناء بطاقة التحضير
  Widget _buildPreparationCard() {
    final List<String> preparationSteps = [
      'Arrive 15 minutes before your appointment',
      'Bring your insurance card and ID',
      'Brush your teeth before the appointment',
      'Avoid eating 2 hours before cleaning',
    ];

    return _CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preparation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ...preparationSteps.map((step) => _buildBulletPoint(step)).toList(),
        ],
      ),
    );
  }

  // بناء عنصر نقطة التعداد
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6.0, right: 8.0),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // بناء أزرار الإجراءات في الأسفل (تم التعديل هنا)
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // زري الاتصال والرسالة
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: منطق الاتصال بالعيادة
                  print('Call Clinic tapped');
                },
                icon: const Icon(Icons.phone, size: 20),
                label: const Text('Call Clinic'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: منطق إرسال رسالة
                  print('Message tapped');
                },
                icon: const Icon(Icons.message_outlined, size: 20),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // زر إعادة الجدولة
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/bookAppointment');
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Reschedule Appointment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // زر إلغاء الموعد
        TextButton(
          onPressed: () {
            // **التنقل:** إظهار رسالة تأكيد الإلغاء
            _showCancelDialog(context);
          },
          child: const Text(
            'Cancel Appointment',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // دالة لإظهار رسالة تأكيد الإلغاء
  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text(
            'Are you sure you want to cancel this appointment? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No, Keep', style: TextStyle(color: primaryColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // إغلاق الـ Dialog
              },
            ),
            TextButton(
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // إغلاق الـ Dialog
                // TODO: منطق الإلغاء الفعلي
                // **التنقل:** العودة إلى الشاشة الرئيسية (أو شاشة المواعيد)
                Navigator.pop(context);
                // أو Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  // بناء صف تفاصيل واحدة (مثل الطبيب، المدة، الموقع)
  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// عنصر مخصص للبطاقة لتجنب التكرار في التصميم
class _CustomCard extends StatelessWidget {
  final Widget child;
  const _CustomCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
