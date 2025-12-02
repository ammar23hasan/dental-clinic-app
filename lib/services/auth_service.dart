import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ...existing code...

Future<void> registerUser({
  required String email,
  required String password,
  required String fullName,
  required String phone,
}) async {
  try {
    // 1. إنشاء الحساب في Authentication
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. الحصول على الـ UID الخاص بالمستخدم الجديد
    String uid = userCredential.user!.uid;

    // 3. إنشاء ملف للمستخدم في Firestore فوراً
    // لاحظ استخدام .doc(uid).set(...) لضمان تطابق الـ ID
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // نجاح التسجيل
    // print("تم إنشاء الحساب والملف بنجاح ✅");
  } on FirebaseAuthException catch (authErr) {
    // يمكن إعادة رفع الخطأ أو التعامل به في الشاشة المستدعية
    rethrow;
  } on FirebaseException catch (fsErr) {
    // أخطاء Firestore (مثال: permission-denied)
    rethrow;
  } catch (e) {
    // أخطاء عامة
    rethrow;
  }
}

// ...existing code...