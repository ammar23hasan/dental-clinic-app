// lib/screens/report_problem_screen.dart

import 'package:flutter/material.dart';
import '../constants.dart'; // افترض وجود ملف الثوابت للألوان

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  String? _issueType;

  // قائمة أنواع المشاكل
  final List<String> issueTypes = [
    'Bug/Error',
    'Login/Account Issue',
    'Appointment Booking Failure',
    'UI/Design Issue',
    'Other',
  ];

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      // عرض رسالة بسيطة للتأكيد
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully! Thank you.'),
        ),
      );

      // هنا يمكن تنفيذ منطق إرسال البيانات إلى الخادم/البريد الإلكتروني
      print('Report Submitted:');
      print('Type: $_issueType');
      print('Subject: ${_subjectController.text}');
      print('Details: ${_detailsController.text}');

      // العودة إلى الشاشة السابقة (Help & Support)
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report a Problem',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Tell us what went wrong so we can fix it quickly.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // 1. نوع المشكلة (Dropdown)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Issue Type',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                initialValue: _issueType,
                items: issueTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _issueType = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select an issue type.' : null,
              ),
              const SizedBox(height: 20),

              // 2. موضوع المشكلة
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject (e.g., App crashed when booking)',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a brief subject for your report.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. تفاصيل المشكلة
              TextFormField(
                controller: _detailsController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Detailed description of the problem',
                  hintText:
                      'Describe the steps you took and what result you expected.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide details about the problem.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // زر الإرسال
              ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Submit Report',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
