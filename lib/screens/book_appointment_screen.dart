import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../models/appointment_model.dart';
import 'package:characters/characters.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final Color primaryColor = kPrimaryColor;

  int? _selectedServiceIndex;

  // ✅ التاريخ والوقت كـ state حقيقي
  DateTime _currentMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 41);

  bool _isLoading = false;

  // اختيار طبيب
  String? _selectedDoctorId;
  String? _selectedDoctorName;

  // أسماء الشهور لعرضها في الهيدر والتخزين في Firestore
  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<Map<String, dynamic>> _services = [
    {
      'title': 'Regular Checkup',
      'duration': '30 min',
      'price': '75',
      'doctor': 'Dr. Sarah Johnson'
    },
    {
      'title': 'Dental Cleaning',
      'duration': '45 min',
      'price': '120',
      'doctor': 'Dr. Michael Chen'
    },
    {
      'title': 'Teeth Whitening',
      'duration': '60 min',
      'price': '200',
      'doctor': 'Dr. Emily Brown'
    },
    {
      'title': 'Root Canal',
      'duration': '90 min',
      'price': '450',
      'doctor': 'Dr. Alex Smith'
    },
  ];

  Appointment? _initialAppointment;
  bool _isEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Appointment && !_isEditing) {
      _initialAppointment = args;
      _isEditing = true;

      // خدمة البداية
      _selectedServiceIndex =
          _services.indexWhere((s) => s['title'] == _initialAppointment!.service);

      // بإمكانك لاحقاً تحليل التاريخ من السترينغ إلى DateTime
      // حاليا نجبر المستخدم يختار تاريخ جديد

      setState(() {});
    }
  }

  // =====================  Helpers  =====================

  String _formatDateForFirestore(DateTime date) {
    final monthName = _monthNames[date.month - 1];
    return '$monthName ${date.day}, ${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // =====================  متابعة/حفظ الموعد  =====================

  void _continueToNextStep() async {
    if (_selectedServiceIndex == null ||
        _selectedDate == null ||
        _selectedDoctorId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please select a service, a doctor and a date to continue.'),
          ),
        );
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to book an appointment.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedService = _services[_selectedServiceIndex!];
      final date = _selectedDate!;
      final selectedDateString = _formatDateForFirestore(date);
      final appointmentTime = _selectedTime.format(context);

      // include doctorId and doctor name (fallback to service doctor if name null)
      final doctorNameToSave = _selectedDoctorName ?? selectedService['doctor'];

      // ⬅️ جديد: نجيب اسم المريض من users
      String patientName = 'Unknown patient';
      String patientEmail = user.email ?? '';

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final userData = userDoc.data();
        if (userData != null) {
          patientName = (userData['fullName'] ?? patientName).toString();
          patientEmail = (userData['email'] ?? patientEmail).toString();
        }
      } catch (_) {
        // If fetching fails, keep defaults but do not block the booking.
      }
    
      final appointmentData = {
        'userId': user.uid ?? '',
        'patientName': patientName,        // ⬅️ جديد
        'patientEmail': patientEmail,      // ⬅️ جديد
        'serviceName': selectedService['title'],
        'doctor': doctorNameToSave,
        'doctorId': _selectedDoctorId,
        'date': selectedDateString,
        'time': appointmentTime,
        'duration': selectedService['duration'],
        'price': selectedService['price'],
        'status': _isEditing ? 'Rescheduled' : 'Pending',
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (_isEditing && _initialAppointment != null) {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(_initialAppointment!.id)
            .update(appointmentData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment successfully rescheduled!'),
            ),
          );
        }
      } else {
        final dataToAdd = Map<String, dynamic>.from(appointmentData);
        dataToAdd['createdAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('appointments')
            .add(dataToAdd);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment successfully booked!'),
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Operation failed: $e. Check Firebase Security Rules.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =====================  UI  =====================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Reschedule Appointment' : 'Book Appointment',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Text(
                'Select Service',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              _buildServiceList(),

              const SizedBox(height: 12),
              _buildDoctorDropdown(),
              const SizedBox(height: 30),

              const Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              _buildCalendar(),
              const SizedBox(height: 30),

              _buildTimeSelector(),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _continueToNextStep,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditing ? 'Confirm Reschedule' : 'Continue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ------------ قائمة الخدمات ------------
  Widget _buildServiceList() {
    return Column(
      children: List.generate(_services.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedServiceIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _selectedServiceIndex == index
                      ? primaryColor
                      : Theme.of(context).dividerColor,
                  width: _selectedServiceIndex == index ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _services[index]['title']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _selectedServiceIndex == index
                              ? primaryColor
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _services[index]['duration']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _services[index]['price']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _selectedServiceIndex == index
                          ? primaryColor
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          )
        );
      }),
    );
  }

  // ------------ قائمة الأطباء ------------
  Widget _buildDoctorDropdown() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('doctors')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(color: kPrimaryColor),
          );
        }

        if (snapshot.hasError) {
          return Text('Error loading doctors: ${snapshot.error}');
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Text(
            'No doctors available. Please contact the clinic.',
            style: TextStyle(color: Colors.red),
          );
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedDoctorId,
          decoration: const InputDecoration(
            labelText: 'Choose Doctor',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.medical_services),
          ),
          items: docs.map((doc) {
            final data = doc.data();
            final name = (data['name'] ?? 'Unknown').toString();
            final specialty = (data['specialty'] ?? '').toString();
            return DropdownMenuItem<String>(
              value: doc.id,
              child: Text(
                specialty.isNotEmpty ? '$name – $specialty' : name,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDoctorId = value;
              if (value != null) {
                final chosenDoc = docs.firstWhere((d) => d.id == value);
                _selectedDoctorName =
                    (chosenDoc.data()['name'] ?? 'Unknown').toString();
              } else {
                _selectedDoctorName = null;
              }
            });
          },
        );
      },
    );
  }

  // ------------ التقويم الديناميكي ------------
  Widget _buildCalendar() {
    // بداية الشهر الحالي
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    // عدد الأيام في الشهر
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    // offset لبداية الأسبوع (نجعل الأحد = 0)
    final startOffset = firstDayOfMonth.weekday % 7;

    final List<DateTime?> items = List.generate(
      startOffset + daysInMonth,
      (index) {
        if (index < startOffset) return null;
        final day = index - startOffset + 1;
        return DateTime(_currentMonth.year, _currentMonth.month, day);
      },
    );

    final monthLabel =
        '${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}';

    final dowColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          // رأس التقويم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                          1,
                        );
                      });
                    },
                    child: Icon(Icons.arrow_back_ios,
                        color: Colors.grey.shade600, size: 18),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month + 1,
                          1,
                        );
                      });
                    },
                    child: Icon(Icons.arrow_forward_ios,
                        color: primaryColor, size: 18),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayOfWeekLabel('SUN', dowColor),
              _DayOfWeekLabel('MON', dowColor),
              _DayOfWeekLabel('TUE', dowColor),
              _DayOfWeekLabel('WED', dowColor),
              _DayOfWeekLabel('THU', dowColor),
              _DayOfWeekLabel('FRI', dowColor),
              _DayOfWeekLabel('SAT', dowColor),
            ],
          ),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final date = items[index];
              if (date == null) return const SizedBox.shrink();

              final isSelected =
                  _selectedDate != null && _isSameDay(date, _selectedDate!);

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ------------ اختيار الوقت ------------
  Widget _buildTimeSelector() {
    final timeText = _selectedTime.format(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (picked != null) {
                setState(() {
                  _selectedTime = picked;
                });
              }
            },
            child: Row(
              children: [
                Text(
                  timeText,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.access_time, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// label لأيام الأسبوع
class _DayOfWeekLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _DayOfWeekLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
