import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';
import '../models/bike_model.dart';
import '../models/customer_model.dart';
import '../views/pos/invoice_screen.dart';

class SalesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var availableBikes = <BikeModel>[].obs;
  var customers = <CustomerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAvailableBikes();
    fetchCustomers();
  }

  void fetchAvailableBikes() {
    _firestore
        .collection('bikes')
        .where('status', isEqualTo: 'Available')
        .snapshots()
        .listen((snapshot) {
      availableBikes.value =
          snapshot.docs.map((doc) => BikeModel.fromFirestore(doc)).toList();
    });
  }

  void fetchCustomers() {
    _firestore.collection('customers').snapshots().listen((snapshot) {
      customers.value =
          snapshot.docs.map((doc) => CustomerModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> processSale(SaleModel sale) async {
    try {
      isLoading(true);

      final bikeDoc = await _firestore.collection('bikes').doc(sale.bikeId).get();
      final bikeData = bikeDoc.data() ?? {};
      final double buyPrice =
          double.tryParse(bikeData['purchasePrice']?.toString() ?? '0') ?? 0.0;
      final double netSalePrice = sale.salePrice - sale.discount;
      final double saleProfit = netSalePrice - buyPrice;

      WriteBatch batch = _firestore.batch();

      DocumentReference saleRef = _firestore.collection('sales').doc();
      final saleMap = sale.toMap();
      saleMap['purchasePrice'] = buyPrice;
      saleMap['profit'] = saleProfit;
      batch.set(saleRef, saleMap);

      DocumentReference bikeRef = _firestore.collection('bikes').doc(sale.bikeId);
      batch.update(bikeRef, {
        'status': 'Sold',
        'soldPrice': netSalePrice,
        'profit': saleProfit,
      });

      if (sale.dueAmount > 0) {
        DocumentReference customerRef =
        _firestore.collection('customers').doc(sale.customerId);
        batch.update(customerRef, {
          'totalDue': FieldValue.increment(sale.dueAmount),
          'bikeDetails': sale.bikeDetails,
        });
      }

      await batch.commit();

      if (sale.paidAmount > 0) {
        await _firestore.collection('transactions').add({
          'type': 'নতুন বিক্রি (Downpayment)',
          'amount': sale.paidAmount,
          'purchasePrice': buyPrice,
          'salePrice': netSalePrice,
          'profit': saleProfit,
          'customerName': sale.customerName,
          'date': FieldValue.serverTimestamp(),
        });
      }

      Get.snackbar(
        "Success",
        "গাড়িটি সফলভাবে বিক্রি হয়েছে!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Get.to(() => InvoiceScreen(sale: sale));
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        "বিক্রি সম্পন্ন করতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}