// lib/screens/clinic_services_screen.dart (الكود المحدّث)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class ClinicServicesScreen extends StatefulWidget {
  const ClinicServicesScreen({super.key});

  @override
  State<ClinicServicesScreen> createState() => _ClinicServicesScreenState();
}

class _ClinicServicesScreenState extends State<ClinicServicesScreen> {
  String _searchText = '';
  String _selectedCategory = 'All';

  List<Map<String, dynamic>> _filterServices(
      List<Map<String, dynamic>> services) {
    return services.where((service) {
      final name = (service['name'] ?? '').toString().toLowerCase();
      final nameMatches = name.contains(_searchText.toLowerCase());
      final categoryMatches = _selectedCategory == 'All' ||
          (service['category'] ?? '').toString() == _selectedCategory;
      return nameMatches && categoryMatches;
    }).toList();
  }

  List<String> _buildCategories(List<Map<String, dynamic>> services) {
    final categories = services
        .map((s) => (s['category'] ?? '').toString())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...categories];
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading services: ${snapshot.error}'),
            );
          }

          final services = snapshot.data?.docs
                  .map((doc) => {
                        'id': doc.id,
                        ...doc.data(),
                      })
                  .toList() ??
              [];

          final filtered = _filterServices(services);
          final categories = _buildCategories(services);

          if (!categories.contains(_selectedCategory)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedCategory = 'All';
                });
              }
            });
          }

          return Column(
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
                  children: categories.map((category) {
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
                            color: isSelected
                                ? kPrimaryColor
                                : Colors.transparent,
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
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No services available.'),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final service = filtered[index];
                          return _buildServiceTile(context, service);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // بطاقة عرض الخدمة الواحدة
  Widget _buildServiceTile(BuildContext context, Map<String, dynamic> service) {
    final rawPrice = (service['price'] ?? '').toString();
    final priceText =
        rawPrice.isEmpty ? '—' : (rawPrice.startsWith('\$') ? rawPrice : '\$$rawPrice');

    return ListTile(
      title: Text(
        service['name']?.toString() ?? 'Service',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Category: ${service['category'] ?? '—'}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            priceText,
            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/serviceDetails',
          arguments: service,
        );
      },
    );
  }
}
