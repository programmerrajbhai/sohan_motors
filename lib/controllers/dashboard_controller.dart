import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var totalBikes = 0.obs;
  var totalStockAmount = 0.0.obs; // মোট স্টকের টাকা (Available bikes purchasePrice)
  var todayStockCount = 0.obs; // আজকে যুক্ত হওয়া স্টকের সংখ্যা
  var todayStockAmount = 0.0.obs; // আজকে যুক্ত হওয়া স্টকের টাকা
  var totalCustomers = 0.obs;
  var totalDueAmount = 0.0.obs;
  var totalSalesAmount = 0.0.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  bool _isToday(dynamic timestamp) {
    if (timestamp is! Timestamp) return false;
    DateTime date = timestamp.toDate();
    DateTime now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void fetchDashboardStats() {
    // ১. বাইক স্টক: মোট সংখ্যা, মোট স্টকের টাকা এবং আজকের স্টক
    _firestore.collection('bikes').snapshots().listen((snapshot) {
      int availableCount = 0;
      double stockValue = 0.0;
      int todayCount = 0;
      double todayValue = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status']?.toString() ?? 'Available';
        final purchasePrice = _toDouble(data['purchasePrice']);
        final createdAt = data['createdAt'];

        if (status == 'Available') {
          availableCount++;
          stockValue += purchasePrice;
        }

        if (_isToday(createdAt)) {
          todayCount++;
          todayValue += purchasePrice;
        }
      }

      totalBikes.value = availableCount;
      totalStockAmount.value = stockValue;
      todayStockCount.value = todayCount;
      todayStockAmount.value = todayValue;
      isLoading.value = false;
    }, onError: (_) {
      isLoading.value = false;
    });

    // ২. কাস্টমার এবং মোট বকেয়ার হিসাব
    _firestore.collection('customers').snapshots().listen((snapshot) {
      totalCustomers.value = snapshot.docs.length;
      double tempDue = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        tempDue += _toDouble(data['totalDue']);
      }
      totalDueAmount.value = tempDue;
    });

    // ৩. মোট বিক্রির হিসাব
    _firestore.collection('sales').snapshots().listen((snapshot) {
      double tempSales = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        double price = _toDouble(data['salePrice']);
        double discount = _toDouble(data['discount']);
        double netSale = price - discount;
        tempSales += netSale > 0 ? netSale : price;
      }
      totalSalesAmount.value = tempSales;
    });
  }
}