// lib/screens/my_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../models/appointment_model.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Appointments')),
        body: const Center(child: Text('Please sign in to view your appointments.')),
      );
    }
    
    // بناء استعلام Firestore
    final appointmentsStream = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: currentUser!.uid)
        .orderBy('date', descending: false)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointmentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading appointments: ${snapshot.error}'));
          }
          
          final appointmentsDocs = snapshot.data!.docs;

          if (appointmentsDocs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('No Upcoming Appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text('Tap "Book Appointment" to schedule your first visit.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          final appointments = appointmentsDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Appointment(
              id: doc.id,
              service: data['serviceName'] ?? 'Unknown Service',
              date: data['date'] ?? 'N/A',
              time: data['time'] ?? '',
              doctorName: data['doctor'] ?? 'Unassigned',
              clinicAddress: 'SmileCare Dental Clinic',
              status: data['status'] ?? 'Pending',
              duration: data['duration'] ?? '',
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return _buildAppointmentCard(context, appointment);
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    Color statusColor = appointment.status == 'Confirmed'
        ? Colors.green
        : (appointment.status == 'Pending' ? Colors.orange : Colors.red);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Icon(Icons.calendar_today, color: kPrimaryColor),
        title: Text(appointment.service, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('${appointment.date} at ${appointment.time}\nDr. ${appointment.doctorName}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            appointment.status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/appointmentDetails',
            arguments: appointment,
          );
        },
      ),
    );
  }
}
