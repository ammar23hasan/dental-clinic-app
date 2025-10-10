// lib/screens/faq_screen.dart

import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  // قائمة أسئلة وأجوبة ثابتة
  final List<Map<String, String>> faqData = const [
    {
      'question': 'How can I book a new appointment?',
      'answer':
          'You can book a new appointment directly from the main screen by tapping on the "Book Appointment" card. Select the service, date, and time that suits you.',
    },
    {
      'question': 'How do I change or cancel my appointment?',
      'answer':
          'Go to "My Appointments" from the home screen, select the upcoming appointment, and you will see "Reschedule" and "Cancel" buttons at the bottom.',
    },
    {
      'question': 'What insurance plans do you accept?',
      'answer':
          'We accept most major dental insurance plans. Please contact the clinic directly via phone or email for specific details regarding your provider.',
    },
    {
      'question': 'Can I update my personal information?',
      'answer':
          'Yes, navigate to your Profile (top right icon), and tap the edit icon to change your name, email, or phone number.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        itemCount: faqData.length,
        itemBuilder: (context, index) {
          final item = faqData[index];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ExpansionTile(
              // السؤال (Question)
              title: Text(
                item['question']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // الإجابة (Answer)
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  child: Text(
                    item['answer']!,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
