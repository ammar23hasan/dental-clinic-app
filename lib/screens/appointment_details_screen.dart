import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- للاستخدام الجديد
import '../constants.dart';
import '../models/appointment_model.dart'; 

class AppointmentDetailsScreen extends StatelessWidget {
  const AppointmentDetailsScreen({super.key});

  final Color primaryColor = kPrimaryColor;
  final Color confirmedColor = const Color(0xFF69F0AE);

  // دالة الإلغاء: الآن تحذف من Firestore
  void _cancelAppointment(BuildContext context, String appointmentId) {
    // عرض نافذة تأكيد قبل الإلغاء (ضروري)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Cancellation'),
        content: const Text('Are you sure you want to cancel this appointment? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: const Text('No, Keep'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // إغلاق نافذة التأكيد

              try {
                // 1. حذف المستند من مجموعة 'appointments'
                await FirebaseFirestore.instance
                    .collection('appointments')
                    .doc(appointmentId)
                    .delete();

                // 2. إظهار رسالة نجاح
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment successfully cancelled!')),
                );
                
                // 3. العودة إلى شاشة المواعيد القادمة
                Navigator.pop(context); 
                
              } catch (e) {
                // التعامل مع أخطاء الحذف
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to cancel appointment: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  // دوال الإجراءات الخارجية الوهمية
  void _callClinic(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling clinic...')),
    );
  }

  // updated: accept the appointment and forward it to the booking screen for editing
  void _reschedule(BuildContext context, Appointment appointment) {
    Navigator.pushNamed(
      context,
      '/bookAppointment',
      arguments: appointment,
    );
  }

  // دوال بناء البطاقات (للتصميم)
  Widget _buildDetailRow(BuildContext context, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPrimaryColor, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16,   color: Theme.of(context).textTheme.bodyLarge!.color,
                    fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineButton(BuildContext context, String text, IconData icon, Function(BuildContext) onTap) {
    return OutlinedButton.icon(
      onPressed: () => onTap(context),
      icon: Icon(icon, color: kPrimaryColor),
      label: Text(text, style: TextStyle(color: kPrimaryColor)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(55),
        side: BorderSide(color: kPrimaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, Appointment appointment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold
            )),
            const Divider(height: 20),
            _buildDetailRow(context, Icons.person, appointment.doctorName, 'Dentist'),
            _buildDetailRow(context, Icons.schedule, appointment.duration, 'Duration'),
            _buildDetailRow(context, Icons.location_on, appointment.clinicAddress, 'SmileCare Dental Clinic'),
          ],
        ),
      ),
    );
  }

  Widget _buildPreparationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Preparation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            _buildBulletPoint('Arrive 15 minutes before your appointment'),
            _buildBulletPoint('Bring your insurance card and ID'),
            _buildBulletPoint('Brush your teeth before the appointment'),
            _buildBulletPoint('Avoid eating 2 hours before cleaning'),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(Appointment appointment) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: kPrimaryColor,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const Icon(Icons.calendar_today, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(appointment.service, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${appointment.date} at ${appointment.time}', style: const TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                appointment.status.toUpperCase(),
                style: TextStyle(color: kPrimaryColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(5)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final appointment = ModalRoute.of(context)!.settings.arguments as Appointment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // ********** بطاقة الموعد الرئيسية **********
                  _buildMainCard(appointment),
                  const SizedBox(height: 20),
                  
                  // ********** بطاقة التفاصيل **********
                  _buildDetailsCard(context, appointment),
                  const SizedBox(height: 20),

                  // ********** بطاقة التحضير **********
                  _buildPreparationCard(),
                ],
              ),
            ),
          ),

          // ********** أزرار الإجراءات في الأسفل **********
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildOutlineButton(context, 'Call Clinic', Icons.phone, _callClinic)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildOutlineButton(context, 'Message', Icons.message, (ctx) {})),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => _reschedule(context, appointment), // pass appointment to reschedule
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(55),
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Reschedule Appointment', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => _cancelAppointment(context, appointment.id),
                  child: const Text('Cancel Appointment', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
