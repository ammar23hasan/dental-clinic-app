import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  final CollectionReference<Map<String, dynamic>> _servicesRef =
      FirebaseFirestore.instance.collection('services');

  Future<void> _showServiceDialog({
    DocumentSnapshot<Map<String, dynamic>>? doc,
  }) async {
    final isEdit = doc != null;
    final data = doc?.data() ?? {};

    final nameController = TextEditingController(text: data['name']?.toString() ?? '');
    final categoryController =
        TextEditingController(text: data['category']?.toString() ?? '');
    final priceController =
        TextEditingController(text: data['price']?.toString() ?? '');
    final durationController =
        TextEditingController(text: data['duration']?.toString() ?? '');
    final recoveryController =
        TextEditingController(text: data['recovery']?.toString() ?? '');
    final descriptionController =
        TextEditingController(text: data['description']?.toString() ?? '');
    final doctorIdController =
        TextEditingController(text: data['doctorId']?.toString() ?? '');
    final doctorNameController =
        TextEditingController(text: data['doctorName']?.toString() ?? '');

    bool isSubmitting = false;
    bool dialogClosed = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            color: kPrimaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isEdit ? 'Edit Service' : 'Add Service',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Service Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: recoveryController,
                      decoration: const InputDecoration(
                        labelText: 'Recovery',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: doctorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Default Doctor Name (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: doctorIdController,
                      decoration: const InputDecoration(
                        labelText: 'Default Doctor Id (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  dialogClosed = true;
                                  Navigator.pop(context);
                                },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final name = nameController.text.trim();
                                  final category = categoryController.text.trim();
                                  final price = priceController.text.trim();
                                  final duration = durationController.text.trim();
                                  final recovery = recoveryController.text.trim();
                                  final description =
                                      descriptionController.text.trim();
                                  final doctorId = doctorIdController.text.trim();
                                  final doctorName =
                                      doctorNameController.text.trim();

                                  if (name.isEmpty || category.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Name and category are required.'),
                                      ),
                                    );
                                    return;
                                  }

                                  setDialogState(() {
                                    isSubmitting = true;
                                  });

                                  try {
                                    final payload = <String, dynamic>{
                                      'name': name,
                                      'category': category,
                                      'price': price,
                                      'duration': duration,
                                      'recovery': recovery,
                                      'description': description,
                                      'doctorId': doctorId.isEmpty ? null : doctorId,
                                      'doctorName':
                                          doctorName.isEmpty ? null : doctorName,
                                      'updatedAt': FieldValue.serverTimestamp(),
                                    };

                                    if (isEdit) {
                                      await doc.reference.set(
                                        payload,
                                        SetOptions(merge: true),
                                      );
                                    } else {
                                      payload['createdAt'] =
                                          FieldValue.serverTimestamp();
                                      await _servicesRef.add(payload);
                                    }

                                    if (context.mounted) {
                                      dialogClosed = true;
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to save service: $e'),
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (!dialogClosed && context.mounted) {
                                      setDialogState(() {
                                        isSubmitting = false;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isEdit ? 'Save' : 'Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameController.dispose();
      categoryController.dispose();
      priceController.dispose();
      durationController.dispose();
      recoveryController.dispose();
      descriptionController.dispose();
      doctorIdController.dispose();
      doctorNameController.dispose();
    });
  }

  Future<void> _deleteService(DocumentReference<Map<String, dynamic>> ref) async {
    try {
      await ref.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete service: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Services',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _servicesRef.orderBy('name').snapshots(),
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

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('No services found. Tap + to add one.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final name = (data['name'] ?? 'Service').toString();
              final category = (data['category'] ?? '').toString();
              final price = (data['price'] ?? '').toString();

              return ListTile(
                tileColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  category.isEmpty ? 'Uncategorized' : category,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (price.isNotEmpty)
                      Text(
                        price.startsWith('\$') ? price : '\$$price',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showServiceDialog(doc: doc);
                        } else if (value == 'delete') {
                          _deleteService(doc.reference);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceDialog(),
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
      ),
    );
  }
}
