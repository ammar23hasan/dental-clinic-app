import 'package:flutter/material.dart';
import '../constants.dart';

class ServiceDetailsScreen extends StatelessWidget {
  // استقبال اسم الخدمة كمعامل (لجعله ديناميكياً)
  final String serviceName;

  const ServiceDetailsScreen({super.key, required this.serviceName});

  // بيانات وهمية إضافية تعتمد على اسم الخدمة
  String get _description {
    switch (serviceName) {
      case 'Dental Cleaning':
        return 'Professional removal of plaque and tartar to prevent gum disease and decay. Recommended every 6 months.';
      case 'Teeth Whitening':
        return 'Quick and effective treatment to lighten the color of your teeth, removing stains and discoloration.';
      default:
        return 'Detailed description for this service is coming soon. Please contact the clinic for more info.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          serviceName,
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // عنوان ووصف
            Text(
              serviceName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
            const SizedBox(height: 10),
            Text(
              _description,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 40),

            // معلومات الخدمة
            _buildInfoTile(
              context,
              Icons.schedule,
              'Duration',
              'Approx. 45 - 90 minutes',
            ),
            _buildInfoTile(context, Icons.attach_money, 'Price Range', '\$120 - \$500'),
            _buildInfoTile(context, Icons.healing, 'Recovery', 'Immediate'),

            const SizedBox(height: 50),

            // ********** زر الإجراء الفوري (Call to Action) **********
            ElevatedButton(
              onPressed: () {
                // التنقل: يذهب لشاشة حجز الموعد مع تحديد الخدمة تلقائياً (WIP)
                // حالياً يذهب للمسار الأساسي للحجز
                Navigator.pushNamed(context, '/bookAppointment');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(55),
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Book This Service',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            // زر استفسار
            TextButton(
              onPressed: () {
                print('Contact button for $serviceName pressed');
              },
              child: const Text(
                'Ask a Question about this Service',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildInfoTile(BuildContext context, IconData icon, String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Row(
      children: [
        Icon(icon, color: kPrimaryColor, size: 24),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}
