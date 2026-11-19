import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/customer_model.dart';

class ExpenseItem {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  factory ExpenseItem.fromDoc(DocumentSnapshot doc) {
    final rawData = doc.data();
    final Map<String, dynamic> data =
    rawData is Map<String, dynamic> ? rawData : {};

    final rawAmt = data['amount'];
    final double parsedAmt = rawAmt is num
        ? rawAmt.toDouble()
        : (double.tryParse(rawAmt?.toString() ?? '0') ?? 0.0);

    final rawDate = data['date'];
    final DateTime parsedDate =
    rawDate is Timestamp ? rawDate.toDate() : DateTime.now();

    return ExpenseItem(
      id: doc.id,
      title: data['title']?.toString() ?? 'খরচ',
      category: data['category']?.toString() ?? 'Daily Cost',
      amount: parsedAmt,
      date: parsedDate,
    );
  }
}

class ReportsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = true.obs;
  final currentStockValue = 0.0.obs;
  final totalIncome = 0.0.obs;
  final todayIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final todayExpense = 0.0.obs;
  final totalCostWithStock = 0.0.obs;
  final grossProfit = 0.0.obs;
  final netProfitAfterTotalCost = 0.0.obs;
  final netProfitAfterDailyCost = 0.0.obs;

  final isAddingExpense = false.obs;
  final expenses = [].obs;
  final overdueCustomers = [].obs;
  final transactions = [].obs;

  double _rawGrossProfit = 0.0;
  double _rawSalesIncome = 0.0;
  double _rawTransactionsIncome = 0.0;
  double _rawTodayTransactionsIncome = 0.0;

  @override
  void onInit() {
    super.onInit();
    fetchReportsData();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _recalculateFinancials() {
    final double incomeFromSalesOrTx =
    _rawSalesIncome > 0 ? _rawSalesIncome : _rawTransactionsIncome;

    totalIncome.value = incomeFromSalesOrTx;
    todayIncome.value = _rawTodayTransactionsIncome;
    grossProfit.value = _rawGrossProfit;

    totalCostWithStock.value = currentStockValue.value + totalExpense.value;
    netProfitAfterTotalCost.value = _rawGrossProfit - totalExpense.value;
    netProfitAfterDailyCost.value = _rawGrossProfit - todayExpense.value;
  }

  void fetchReportsData() {
    // ১. বর্তমান স্টকের মোট মূল্য (Available bikes purchasePrice)
    _firestore
        .collection('bikes')
        .where('status', isEqualTo: 'Available')
        .snapshots()
        .listen((snap) {
      double stock = 0.0;
      for (final doc in snap.docs) {
        final raw = doc.data();
        final Map<String, dynamic> data =
        raw is Map<String, dynamic> ? raw : {};
        stock += _toDouble(data['purchasePrice']);
      }
      currentStockValue.value = stock;
      _recalculateFinancials();
    });

    // ২. বিক্রির আয় ও গ্রস প্রফিট হিসাব
    _firestore.collection('sales').snapshots().listen((salesSnap) async {
      double salesTotal = 0.0;
      double directProfitSum = 0.0;
      bool hasStoredProfit = false;

      for (final doc in salesSnap.docs) {
        final raw = doc.data();
        final Map<String, dynamic> data =
        raw is Map<String, dynamic> ? raw : {};
        final salePrice = _toDouble(data['salePrice']);
        final discount = _toDouble(data['discount']);
        final netSale =
        (salePrice - discount) > 0 ? (salePrice - discount) : salePrice;
        salesTotal += netSale;

        if (data['profit'] != null) {
          hasStoredProfit = true;
          directProfitSum += _toDouble(data['profit']);
        } else if (data['purchasePrice'] != null) {
          hasStoredProfit = true;
          directProfitSum += (netSale - _toDouble(data['purchasePrice']));
        }
      }

      _rawSalesIncome = salesTotal;

      if (hasStoredProfit) {
        _rawGrossProfit = directProfitSum;
      } else {
        final soldSnap = await _firestore
            .collection('bikes')
            .where('status', isEqualTo: 'Sold')
            .get();
        double totalPurchaseOfSold = 0.0;
        for (final doc in soldSnap.docs) {
          final raw = doc.data();
          final Map<String, dynamic> data =
          raw is Map<String, dynamic> ? raw : {};
          totalPurchaseOfSold += _toDouble(data['purchasePrice']);
        }
        _rawGrossProfit = salesTotal - totalPurchaseOfSold;
      }

      _recalculateFinancials();
    });

    // ৩. শোরুমের দৈনিক খরচ ও অন্যান্য খরচ
    _firestore
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      double expSum = 0.0;
      double todayExpSum = 0.0;
      final expList = [];

      for (final doc in snap.docs) {
        final item = ExpenseItem.fromDoc(doc);
        expList.add(item);
        expSum += item.amount;
        if (_isToday(item.date)) {
          todayExpSum += item.amount;
        }
      }

      expenses.assignAll(expList);
      totalExpense.value = expSum;
      todayExpense.value = todayExpSum;
      _recalculateFinancials();
    });

    // ৪. কিস্তি মিস করা কাস্টমারদের লিস্ট (Overdue)
    _firestore
        .collection('customers')
        .where('totalDue', isGreaterThan: 0)
        .snapshots()
        .listen((snap) {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);

      final overdue = snap.docs
          .map((d) => CustomerModel.fromFirestore(d))
          .where((c) =>
      c.nextInstallmentDate != null &&
          c.nextInstallmentDate!.isBefore(startOfToday))
          .toList();

      overdueCustomers.assignAll(overdue);
    });

    // ৫. দৈনিক আদায় ও লেনদেনের রেকর্ড
    _firestore
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      double txSum = 0.0;
      double todayTxSum = 0.0;
      final txItems = [];

      for (final d in snap.docs) {
        final raw = d.data();
        final Map<String, dynamic> data =
        raw is Map<String, dynamic> ? raw : {};
        txItems.add(data);
        final typeStr = data['type']?.toString() ?? '';
        if (!typeStr.contains('ডিসকাউন্ট')) {
          final amt = _toDouble(data['amount']);
          txSum += amt;
          final rawDate = data['date'];
          if (rawDate is Timestamp && _isToday(rawDate.toDate())) {
            todayTxSum += amt;
          }
        }
      }

      transactions.assignAll(txItems);
      _rawTransactionsIncome = txSum;
      _rawTodayTransactionsIncome = todayTxSum;
      _recalculateFinancials();
      isLoading.value = false;
    }, onError: (_) {
      isLoading.value = false;
    });
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
  }) async {
    try {
      isAddingExpense.value = true;
      await _firestore.collection('expenses').add({
        'title': title.trim(),
        'category': category,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.back();
      Get.snackbar(
        "Success",
        "খরচ সফলভাবে যুক্ত হয়েছে এবং নিট লাভ আপডেট হয়েছে!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "খরচ সেভ করতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isAddingExpense.value = false;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).delete();
      Get.snackbar(
        "Deleted",
        "খরচের এন্ট্রিটি মুছে ফেলা হয়েছে।",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "ডিলিট করতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}