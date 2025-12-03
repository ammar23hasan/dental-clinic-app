// lib/screens/clinic_services_screen.dart (الكود المحدّث)

import 'package:flutter/material.dart';
import '../constants.dart';

class ClinicServicesScreen extends StatefulWidget {
  const ClinicServicesScreen({super.key});

  @override
  State<ClinicServicesScreen> createState() => _ClinicServicesScreenState();
}

class _ClinicServicesScreenState extends State<ClinicServicesScreen> {
  final List<Map<String, String>> _allServices = const [
    {'name': 'Dental Cleaning', 'category': 'Preventive', 'price': '\$120'},
    {'name': 'Teeth Whitening', 'category': 'Cosmetic', 'price': '\$250'},
    {'name': 'Root Canal', 'category': 'Restorative', 'price': '\$450'},
    {'name': 'Regular Checkup', 'category': 'Preventive', 'price': '\$75'},
    {'name': 'Veneers', 'category': 'Cosmetic', 'price': '\$900'},
    {'name': 'Tooth Extraction', 'category': 'Surgical', 'price': '\$200'},
  ];

  String _searchText = '';
  String _selectedCategory = 'All';

  // قائمة الفئات
  List<String> get _categories => [
    'All',
    'Preventive',
    'Cosmetic',
    'Restorative',
    'Surgical',
  ];

  // دالة الفلترة
  List<Map<String, String>> get _filteredServices {
    return _allServices.where((service) {
      final nameMatches = service['name']!.toLowerCase().contains(
        _searchText.toLowerCase(),
      );
      final categoryMatches =
          _selectedCategory == 'All' ||
          service['category'] == _selectedCategory;
      return nameMatches && categoryMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clinic Services',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for a service...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 10,
                ),
              ),
            ),
          ),

          // شريط الفلترة (الفئات)
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ActionChip(
                    label: Text(category),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: isSelected
                        ? kPrimaryColor
                        : Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? kPrimaryColor : Colors.transparent,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // قائمة الخدمات
          Expanded(
            child: ListView.builder(
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                final service = _filteredServices[index];
                return _buildServiceTile(context, service);
              },
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة عرض الخدمة الواحدة
  Widget _buildServiceTile(BuildContext context, Map<String, String> service) {
    return ListTile(
      title: Text(
        service['name']!,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Category: ${service['category']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            service['price']!,
            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: () {
        // التنقل: يذهب إلى شاشة تفاصيل الخدمة مع تمرير الاسم
        Navigator.pushNamed(
          context,
          '/serviceDetails',
          arguments: service['name'],
        );
      },
    );
  }
}
