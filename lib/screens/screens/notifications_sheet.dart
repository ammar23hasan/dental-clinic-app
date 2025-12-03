import 'package:flutter/material.dart';
import '../constants.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  // بيانات وهمية للإشعارات
  final List<Map<String, String>> notifications = const [
    {
      'title': 'Appointment Confirmed',
      'body': 'Your checkup with Dr. Chen on Aug 22nd is confirmed.',
      'time': '2m ago',
    },
    {
      'title': 'Reminder: Payment Due',
      'body': 'A payment of \$450 for Root Canal is due soon.',
      'time': '1h ago',
    },
    {
      'title': 'New Clinic Offer',
      'body': 'Enjoy 20% off on Teeth Whitening this week!',
      'time': '1d ago',
    },
    {
      'title': 'System Update',
      'body': 'New features and bug fixes have been deployed.',
      'time': '3d ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Column(
        children: [
          // شريط السحب والإغلاق
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
            child: Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // العنوان
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                // زر إغلاق (اختياري)
                // IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),

          // فاصل
          const Divider(height: 1, thickness: 1, color: Colors.grey),

          // قائمة الإشعارات
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kPrimaryColor.withOpacity(0.1),
                    child: Icon(
                      index == 0 ? Icons.calendar_today : Icons.info_outline,
                      color: kPrimaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    notification['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(notification['body']!),
                  trailing: Text(
                    notification['time']!,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    // TODO: منطق فتح تفاصيل الإشعار
                    Navigator.pop(context); // إغلاق الشيت بعد الضغط
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
