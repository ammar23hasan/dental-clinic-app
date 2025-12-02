import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // للوصول لمعرّف المستخدم
import 'package:cloud_firestore/cloud_firestore.dart'; // للوصول لقاعدة البيانات
import '../constants.dart'; // ملف الثوابت (يجب أن يحتوي على kPrimaryColor)
import '../models/appointment_model.dart'; // <--- استيراد نموذج الموعد

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final Color primaryColor = kPrimaryColor;
  int? _selectedServiceIndex;
  int? _selectedDate; // لم يعد يحتاج لقيمة وهمية
  bool _isLoading = false;

  // قائمة الخدمات
  final List<Map<String, dynamic>> _services = [
    {'title': 'Regular Checkup', 'duration': '30 min', 'price': '75', 'doctor': 'Dr. Sarah Johnson'},
    {'title': 'Dental Cleaning', 'duration': '45 min', 'price': '120', 'doctor': 'Dr. Michael Chen'},
    {'title': 'Teeth Whitening', 'duration': '60 min', 'price': '200', 'doctor': 'Dr. Emily Brown'},
    {'title': 'Root Canal', 'duration': '90 min', 'price': '450', 'doctor': 'Dr. Alex Smith'},
  ];

  // لتهيئة الحقول في حالة التعديل
  Appointment? _initialAppointment;
  bool _isEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // جلب المعاملات (arguments) عند بناء الشاشة
    final args = ModalRoute.of(context)?.settings.arguments;
    
    // التحقق من أننا في وضع التعديل (Reschedule) ولم يتم تهيئة القيم بعد
    if (args is Appointment && !_isEditing) {
      _initialAppointment = args;
      _isEditing = true;
      
      // تعيين القيم الافتراضية لحقول التعديل
      _selectedServiceIndex = _services.indexWhere((s) => s['title'] == _initialAppointment!.service);
      
      // هنا يمكنك تحليل التاريخ من الـ String إلى القيمة الصحيحة لـ _selectedDate
      // لكن سنترك القيمة كما هي لغرض استكمال التنفيذ الوظيفي

      setState(() {});
    }
  }

  // دالة التنقل والمتابعة (مع حفظ/تعديل البيانات في Firestore)
  void _continueToNextStep() async {
    if (_selectedServiceIndex == null || _selectedDate == null) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a service and a date to continue.')),
        );
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to book an appointment.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedService = _services[_selectedServiceIndex!];
      final appointmentTime = '9:41 AM (Temp)'; 
      final selectedDateString = 'April $_selectedDate, 2025';

      final appointmentData = {
        'userId': user.uid,
        'serviceName': selectedService['title'],
        'doctor': selectedService['doctor'],
        'date': selectedDateString,
        'time': appointmentTime,
        'duration': selectedService['duration'],
        'price': selectedService['price'],
        'status': _isEditing ? 'Rescheduled' : 'Pending', // تحديث الحالة عند التعديل
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (_isEditing && _initialAppointment != null) {
        // ********** وضع التعديل (Update) **********
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(_initialAppointment!.id)
            .update(appointmentData);

        if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appointment successfully rescheduled!')),
            );
        }
      } else {
        // ********** وضع الإنشاء الجديد (Add) **********
        await FirebaseFirestore.instance.collection('appointments').add(appointmentData);

        if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appointment successfully booked!')),
            );
        }
      }

      if(mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }

    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operation failed: $e. Check Firebase Security Rules.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Reschedule Appointment' : 'Book Appointment', // <--- عنوان ديناميكي
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),

                // ********** قسم اختيار الخدمة **********
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
                const SizedBox(height: 30),

                // ********** قسم اختيار التاريخ **********
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

                // ********** قسم اختيار الوقت **********
                _buildTimeSelector(),
                const SizedBox(height: 30),

                // ********** زر المتابعة **********
                ElevatedButton(
                  onPressed: _isLoading ? null : _continueToNextStep,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditing ? 'Confirm Reschedule' : 'Continue', // <--- نص ديناميكي
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                ),
                
                // مسافة سفلية
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // الدوال المساعدة
  // -------------------------------------------------------------------

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
          ),
        );
      }),
    );
  }

  Widget _buildCalendar() {
    const List<int> days = [
      0,
      0,
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      30,
    ];

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
              const Text(
                'April 2025',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.arrow_back_ios, color: Colors.grey, size: 18),
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_forward_ios, color: primaryColor, size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          // أيام الأسبوع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayOfWeekLabel('SUN', Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
              _DayOfWeekLabel('MON', Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
              _DayOfWeekLabel('TUE', Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
              _DayOfWeekLabel('WED', Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
              _DayOfWeekLabel('THU', Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
              _DayOfWeekLabel('FRI', Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
              _DayOfWeekLabel('SAT', Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
            ],
          ),
          const SizedBox(height: 10),

          // شبكة التواريخ
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == 0) return const SizedBox.shrink();

              final isSelected = day == _selectedDate;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = day;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildTimeSelector() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            '9:41 AM', // مؤقت - يمكن استبداله بـ TimePicker لاحقاً
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// عنصر مساعد لاسم يوم الأسبوع
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
