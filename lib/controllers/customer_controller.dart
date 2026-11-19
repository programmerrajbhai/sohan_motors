import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../views/due/installment_receipt_screen.dart';

class CustomerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final customerList = [].obs;
  final expiredDueCustomers = [].obs;
  final expiredDueAmount = 0.0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool isDateExpired(CustomerModel customer) {
    if (customer.totalDue <= 0 || customer.nextInstallmentDate == null) {
      return false;
    }
    DateTime todayStart = _startOfDay(DateTime.now());
    DateTime dueStart = _startOfDay(customer.nextInstallmentDate!);
    return dueStart.isBefore(todayStart);
  }

  int expiredDaysCount(CustomerModel customer) {
    if (!isDateExpired(customer) || customer.nextInstallmentDate == null) {
      return 0;
    }
    DateTime todayStart = _startOfDay(DateTime.now());
    DateTime dueStart = _startOfDay(customer.nextInstallmentDate!);
    return todayStart.difference(dueStart).inDays;
  }

  void _recalculateExpiredCustomers(List<CustomerModel> allCustomers) {
    final expiredList = allCustomers.where((c) => isDateExpired(c)).toList()
      ..sort((a, b) {
        final dateA = a.nextInstallmentDate ?? DateTime.now();
        final dateB = b.nextInstallmentDate ?? DateTime.now();
        return dateA.compareTo(dateB);
      });

    double totalExpired = 0.0;
    for (var customer in expiredList) {
      totalExpired += customer.totalDue;
    }

    expiredDueCustomers.assignAll(expiredList);
    expiredDueAmount.value = totalExpired;
  }

  void fetchCustomers() {
    _firestore
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      try {
        final parsed = snapshot.docs
            .map((doc) => CustomerModel.fromFirestore(doc))
            .toList();
        customerList.assignAll(parsed);
        _recalculateExpiredCustomers(parsed);
      } catch (e) {
        debugPrint("Customer parse error: $e");
      }
    });
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      isLoading.value = true;
      await _firestore.collection('customers').add(customer.toMap());
      Get.back();
      Get.snackbar(
        "Success",
        "কাস্টমার সফলভাবে যুক্ত হয়েছে!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "কাস্টমার সেভ করতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    if (customer.id == null || customer.id!.isEmpty) {
      Get.snackbar(
        "Error",
        "কাস্টমার ID পাওয়া যায়নি।",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final trimmedComment = customer.installmentComment.trim();

      await _firestore.collection('customers').doc(customer.id).update({
        'name': customer.name.trim(),
        'phone': customer.phone.trim(),
        'address': customer.address.trim(),
        'bikeDetails': customer.bikeDetails.trim(),
        'guarantorName': customer.guarantorName.trim(),
        'guarantorPhone': customer.guarantorPhone.trim(),
        'securityType': customer.securityType,
        'securityDetails': customer.securityType == 'None'
            ? ''
            : customer.securityDetails.trim(),
        'installmentComment': trimmedComment,
        'comment': trimmedComment,
        'totalDue': customer.totalDue < 0 ? 0.0 : customer.totalDue,
        'nextInstallmentDate': customer.totalDue > 0
            ? (customer.nextInstallmentDate != null
            ? Timestamp.fromDate(customer.nextInstallmentDate!)
            : null)
            : null,
      });

      Get.back();
      Get.snackbar(
        "Updated",
        "কাস্টমারের তথ্য সফলভাবে আপডেট হয়েছে!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "কাস্টমার আপডেট করতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    if (customerId.isEmpty) return;

    try {
      isLoading.value = true;
      await _firestore.collection('customers').doc(customerId).delete();
      Get.back();
      Get.snackbar(
        "Deleted",
        "কাস্টমারটি সফলভাবে মুছে ফেলা হয়েছে।",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "কাস্টমার ডিলিট করতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateInstallmentComment(String customerId, String comment) async {
    try {
      isLoading.value = true;
      final trimmed = comment.trim();
      await _firestore.collection('customers').doc(customerId).update({
        'installmentComment': trimmed,
        'comment': trimmed,
      });
      Get.back();
      Get.snackbar(
        "Saved",
        "কিস্তির কমেন্ট আপডেট হয়েছে!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "কমেন্ট সেভ করতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> collectDue(
      CustomerModel customer,
      double amountToCollect,
      DateTime? nextDate, {
        double discountAmount = 0.0,
        String comment = '',
      }) async {
    try {
      isLoading.value = true;

      final double safeCollect = amountToCollect < 0 ? 0.0 : amountToCollect;
      final double safeDiscount = discountAmount < 0 ? 0.0 : discountAmount;
      final double totalReduction = safeCollect + safeDiscount;

      double remaining = customer.totalDue - totalReduction;
      if (remaining < 0) remaining = 0.0;

      final String finalComment = comment.trim().isNotEmpty
          ? comment.trim()
          : customer.installmentComment.trim();

      await _firestore.collection('customers').doc(customer.id).update({
        'totalDue': remaining,
        'nextInstallmentDate': remaining > 0 ? nextDate : null,
        'installmentComment': finalComment,
        'comment': finalComment,
      });

      if (safeCollect > 0) {
        await _firestore.collection('transactions').add({
          'type': 'বকেয়া/কিস্তি আদায়',
          'amount': safeCollect,
          'discount': safeDiscount,
          'comment': finalComment,
          'customerName': customer.name,
          'date': FieldValue.serverTimestamp(),
        });
      }

      if (safeDiscount > 0) {
        await _firestore.collection('transactions').add({
          'type': 'কিস্তি/বকেয়া ডিসকাউন্ট',
          'amount': safeDiscount,
          'collectedAmount': safeCollect,
          'customerName': customer.name,
          'date': FieldValue.serverTimestamp(),
        });
      }

      Get.back();
      Get.snackbar(
        "Success",
        safeDiscount > 0
            ? "৳${safeCollect.toInt()} জমা ও ৳${safeDiscount.toInt()} ডিসকাউন্ট সফলভাবে সেভ হয়েছে!"
            : "কিস্তি সফলভাবে আদায় হয়েছে!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.to(
              () => InstallmentReceiptScreen(
            customerName: customer.name,
            phone: customer.phone,
            collectedAmount: safeCollect,
            remainingDue: remaining,
            nextInstallmentDate: remaining > 0 ? nextDate : null,
          ),
        );
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        "টাকা জমা নিতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}