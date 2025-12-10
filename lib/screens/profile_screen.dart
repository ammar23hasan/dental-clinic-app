import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// <- إضافة لتحديد FirebaseException
import '../constants.dart'; // مسار ملف الثوابت

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryColor = kPrimaryColor; // اللون الأزرق الأساسي
  bool _permissionDeniedNotified = false; // لمنع تكرار الرسالة

  // ********** دوال تسجيل الخروج **********
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmAndSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sign Out')),
        ],
      ),
    );

    if (confirmed == true) {
      await _signOut();
    }
  }

  // دالة لجلب بيانات المستخدم من Firestore (مُحددة النوع)
  Stream<DocumentSnapshot<Map<String, dynamic>>> _getUserDataStream(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  // New: reusable header widget (merged as requested)
  Widget buildProfileHeader(BuildContext context, String fullName, String email, String phone) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor.withOpacity(0.9),
            kPrimaryColor.withOpacity(0.75),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 42,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            fullName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            email,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          if (phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              phone,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Please log in to view your profile.')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // التنقل: يذهب إلى شاشة تعديل الملف الشخصي
              Navigator.pushNamed(context, '/editProfile');
            },
          ),
          // زر تسجيل الخروج في AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: _confirmAndSignOut,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _getUserDataStream(user.uid),
        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          // Firestore permission or other error: show friendly message and fallback to auth data
          if (snapshot.hasError) {
            final err = snapshot.error;
            if (err is FirebaseException && err.code == 'permission-denied') {
              if (!_permissionDeniedNotified) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Permission denied reading profile. Check Firestore rules or project configuration.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // نقل setState إلى هنا لتجنّب استدعائه أثناء البناء
                  setState(() {
                    _permissionDeniedNotified = true;
                  });
                });
              }
              return _buildFallbackProfile(user);
            }
            // other errors
            return Center(child: Text('Error loading profile: ${snapshot.error}'));
          }

          // If no document, fallback to auth info
          final doc = snapshot.data;
          if (doc == null || !doc.exists) {
            return _buildFallbackProfile(user);
          }

          // Normal: use Firestore data
          final userData = doc.data() ?? <String, dynamic>{};
          final String fullName = userData['fullName'] ?? 'User Name';
          final String email = userData['email'] ?? user.email ?? 'No Email';
          final String phone = userData['phoneNumber'] ?? '+1 (555) 123-4567';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20),

                // ********** 1. قسم المعلومات العامة (البطاقة الزرقاء) **********
                buildProfileHeader(context, fullName, email, phone),
                const SizedBox(height: 20),

                // ********** 2. قسم المعلومات الشخصية المفصلة **********
                _buildPersonalInformationCard(fullName: fullName, email: email, phone: phone),
                const SizedBox(height: 30),

                // ********** 3. قسم الإعدادات والخيارات **********
                _buildSettingsOption(context, icon: Icons.notifications_none_outlined, title: 'Notifications', subtitle: 'Manage your notification preferences'),
                _buildSettingsOption(context, icon: Icons.security_outlined, title: 'Privacy & Security', subtitle: 'Update your privacy settings'),
                _buildSettingsOption(context, icon: Icons.settings_outlined, title: 'App Settings', subtitle: 'Customize your app experience'),
                _buildSettingsOption(context, icon: Icons.help_outline, title: 'Help & Support', subtitle: 'Get help or contact support'),

                // خيار تسجيل الخروج الواضح ضمن الإعدادات
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: InkWell(
                    onTap: _confirmAndSignOut,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0,3)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.logout, color: primaryColor),
                          ),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: Text('Sign out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // Fallback UI that uses FirebaseAuth data when Firestore is unavailable
  Widget _buildFallbackProfile(User user) {
    final String fullName = user.displayName ?? 'User Name';
    final String email = user.email ?? 'No Email';
    final String phone = '+1 (555) 123-4567';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 20),
          buildProfileHeader(context, fullName, email, phone),
          const SizedBox(height: 20),
          _buildPersonalInformationCard(fullName: fullName, email: email, phone: phone),
          const SizedBox(height: 30),

          // Small notice + Retry button to re-attempt listening (clears the notification flag)
          Card(
            color: Colors.yellow.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Text(
                    'Unable to read full profile from Firestore. Showing basic info from authentication.',
                    style: TextStyle(color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _permissionDeniedNotified = false; // allow snackbar again if it reoccurs
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          _buildSettingsOption(context, icon: Icons.notifications_none_outlined, title: 'Notifications', subtitle: 'Manage your notification preferences'),
          _buildSettingsOption(context, icon: Icons.security_outlined, title: 'Privacy & Security', subtitle: 'Update your privacy settings'),
          _buildSettingsOption(context, icon: Icons.settings_outlined, title: 'App Settings', subtitle: 'Customize your app experience'),
          _buildSettingsOption(context, icon: Icons.help_outline, title: 'Help & Support', subtitle: 'Get help or contact support'),

          // زر تسجيل الخروج ضمن الـ fallback أيضاً
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton.icon(
              onPressed: _confirmAndSignOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // الدوال المساعدة (Helper Widgets)
  // -------------------------------------------------------------------

  // بناء بطاقة المعلومات الشخصية المفصلة
  Widget _buildPersonalInformationCard({required String fullName, required String email, required String phone}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow(icon: Icons.person_outline, label: 'Full Name', value: fullName),
          _buildInfoRow(icon: Icons.email_outlined, label: 'Email', value: email),
          _buildInfoRow(icon: Icons.call_outlined, label: 'Phone', value: phone),
        ],
      ),
    );
  }
  
  // بناء صف لكل معلومة شخصية
  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // بناء خيارات الإعدادات (البطاقات التي تملأ العرض)
  // ********** الدالة المحدثة للإعدادات (مع منطق التنقل) **********
  Widget _buildSettingsOption(BuildContext? context, {required IconData icon, required String title, required String subtitle}) {
    String routeName;
    if (title == 'Notifications') { routeName = '/notifications'; } 
    else if (title == 'Privacy & Security') { routeName = '/privacySecurity'; } 
    else if (title == 'App Settings') { routeName = '/appSettings'; } 
    else if (title == 'Help & Support') { routeName = '/helpSupport'; } 
    else { routeName = ''; }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: () {
          if (routeName.isNotEmpty) {
            Navigator.pushNamed(context, routeName);
          }
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context!).cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryColor),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
