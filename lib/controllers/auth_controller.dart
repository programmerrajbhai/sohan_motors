import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/auth/login_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;

  // টেক্সট ফিল্ড কন্ট্রোলারে ডিফল্ট ভ্যালু (Auto-fill) সেট করা হয়েছে
  final emailCtrl = TextEditingController(text: 'admin@sohanmotors.com');
  final passwordCtrl = TextEditingController(text: '123456');

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  // লগইন ফাংশন
  Future<void> login() async {
    if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      Get.snackbar("Error", "ইমেইল এবং পাসওয়ার্ড দিন",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading(true);

      // ফায়ারবেস অথেনটিকেশন রিকোয়েস্ট
      await _auth.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      // লগইন সফল হলে ড্যাশবোর্ডে যাবে
      Get.offAll(() => const DashboardScreen());
      Get.snackbar("Success", "লগইন সফল হয়েছে!",
          backgroundColor: Colors.green, colorText: Colors.white);

    } on FirebaseAuthException catch (e) {
      // ফায়ারবেস থেকে আসা নির্দিষ্ট এরর মেসেজ
      String message = "লগইন ব্যর্থ হয়েছে: ${e.message}";

      if (e.code == 'invalid-credential' || e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = "ইমেইল বা পাসওয়ার্ড ভুল হয়েছে। অথবা ফায়ারবেসে অ্যাকাউন্টটি তৈরি করা নেই।";
      }

      Get.snackbar("Login Failed", message,
          backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  // লগআউট ফাংশন
  Future<void> logout() async {
    try {
      await _auth.signOut();

      // কন্ট্রোলার ক্লিয়ার করা (লগআউটের পর ফিল্ড ফাঁকা করতে চাইলে)
      emailCtrl.clear();
      passwordCtrl.clear();

      // লগইন স্ক্রিনে ফেরত পাঠানো
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar("Error", "লগআউট করতে সমস্যা হয়েছে",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}