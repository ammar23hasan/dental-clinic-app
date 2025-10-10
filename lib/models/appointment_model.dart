// Appointment model definition
class Appointment {
  final String id;
  final String service;
  final String date;
  final String time;
  final String doctorName;
  final String clinicAddress;
  final String status;
  final String duration;

  Appointment({
    required this.id,
    required this.service,
    required this.date,
    required this.time,
    required this.doctorName,
    required this.clinicAddress,
    required this.status,
    required this.duration,
  });
}
