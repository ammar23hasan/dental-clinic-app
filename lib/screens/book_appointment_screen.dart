import 'package:flutter/material.dart';
import '../constants.dart'; // ملف الثوابت (يجب أن يحتوي على kPrimaryColor)

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final Color primaryColor = kPrimaryColor;
  int? _selectedServiceIndex;
  int? _selectedDate;

  // قائمة الخدمات
  final List<Map<String, dynamic>> _services = [
    {'title': 'Regular Checkup', 'duration': '30 min', 'price': '\$75'},
    {'title': 'Dental Cleaning', 'duration': '45 min', 'price': '\$120'},
    {'title': 'Teeth Whitening', 'duration': '60 min', 'price': '\$200'},
    {'title': 'Root Canal', 'duration': '90 min', 'price': '\$450'},
  ];

  // دالة التنقل للمتابعة
  void _continueToNextStep() {
    if (_selectedServiceIndex == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service and a date to continue.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.pushNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Book Appointment',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        body: SingleChildScrollView(
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
                onPressed: _continueToNextStep,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _selectedServiceIndex == index
                      ? primaryColor
                      : Colors.grey.shade200,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayOfWeekLabel('SUN', Colors.grey),
              _DayOfWeekLabel('MON', Colors.grey),
              _DayOfWeekLabel('TUE', Colors.grey),
              _DayOfWeekLabel('WED', Colors.grey),
              _DayOfWeekLabel('THU', Colors.grey),
              _DayOfWeekLabel('FRI', Colors.grey),
              _DayOfWeekLabel('SAT', Colors.grey),
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
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
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
