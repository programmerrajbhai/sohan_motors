import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_saver/file_saver.dart';

class ExportController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isLoading = false.obs;

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "N/A";
    DateTime date = (timestamp is Timestamp) ? timestamp.toDate() : (timestamp as DateTime);
    return "${date.day}-${date.month}-${date.year}";
  }

  Future<void> exportBikes() async {
    await _exportData(
      collection: 'bikes',
      fileName: 'Bike_Stock_Report',
      headers: ['ব্র্যান্ড', 'মডেল', 'রঙ', 'চেসিস নম্বর', 'ইঞ্জিন নম্বর', 'কেনার দাম', 'স্ট্যাটাস', 'তারিখ'],
      dataMapper: (doc) => [
        doc['brand'] ?? '',
        doc['model'] ?? '',
        doc['color'] ?? '',
        doc['chassisNo'] ?? '',
        doc['engineNo'] ?? '',
        doc['purchasePrice'] ?? 0,
        doc['status'] ?? '',
        _formatDate(doc['createdAt'])
      ],
    );
  }

  Future<void> exportCustomers() async {
    await _exportData(
      collection: 'customers',
      fileName: 'Customer_List_Report',
      headers: ['কাস্টমারের নাম', 'মোবাইল নম্বর', 'ঠিকানা', 'গাড়ির বিবরণ', 'মোট বকেয়া', 'পরবর্তী কিস্তি', 'যুক্ত হওয়ার তারিখ'],
      dataMapper: (doc) => [
        doc['name'] ?? '',
        doc['phone'] ?? '',
        doc['address'] ?? '',
        doc['bikeDetails'] ?? '',
        doc['totalDue'] ?? 0,
        _formatDate(doc['nextInstallmentDate']),
        _formatDate(doc['createdAt'])
      ],
    );
  }

  Future<void> exportSales() async {
    await _exportData(
      collection: 'sales',
      fileName: 'Sales_History_Report',
      headers: ['কাস্টমারের নাম', 'গাড়ির বিবরণ', 'বিক্রি দাম', 'ডিসকাউন্ট', 'জমা (Paid)', 'বকেয়া (Due)', 'বিক্রির তারিখ'],
      dataMapper: (doc) => [
        doc['customerName'] ?? '',
        doc['bikeDetails'] ?? '',
        doc['salePrice'] ?? 0,
        doc['discount'] ?? 0,
        doc['paidAmount'] ?? 0,
        doc['dueAmount'] ?? 0,
        _formatDate(doc['saleDate'])
      ],
    );
  }

  Future<void> exportTransactions() async {
    await _exportData(
      collection: 'transactions',
      fileName: 'Transactions_Report',
      headers: ['লেনদেনের ধরন', 'কাস্টমারের নাম', 'টাকার পরিমাণ', 'তারিখ'],
      dataMapper: (doc) => [
        doc['type'] ?? '',
        doc['customerName'] ?? '',
        doc['amount'] ?? 0,
        _formatDate(doc['date'])
      ],
    );
  }

  Future<void> _exportData({
    required String collection,
    required String fileName,
    required List<String> headers,
    required List<dynamic> Function(Map<String, dynamic>) dataMapper,
  }) async {
    try {
      isLoading(true);

      QuerySnapshot snapshot = await _firestore.collection(collection).get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar("Empty", "এক্সপোর্ট করার মতো কোনো ডেটা নেই!", backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      List<List<dynamic>> csvData = [headers];

      for (var doc in snapshot.docs) {
        csvData.add(dataMapper(doc.data() as Map<String, dynamic>));
      }

      // নিজস্ব লজিকে CSV তৈরি করা হচ্ছে (প্যাকেজ ছাড়া)
      String csvString = csvData.map((row) {
        return row.map((item) {
          String str = item.toString().replaceAll('"', '""');
          return '"$str"'; // কমা বা স্পেস থাকলেও ডাটা ভাঙবে না
        }).join(',');
      }).join('\n');

      // এক্সেলে বাংলা ফন্ট সাপোর্ট করানোর জন্য UTF-8 BOM (\uFEFF) যুক্ত করা হলো
      List<int> csvBytes = utf8.encode('\uFEFF$csvString');
      Uint8List bytes = Uint8List.fromList(csvBytes);

      String finalFileName = "${fileName}_${DateTime.now().millisecondsSinceEpoch}.csv";

      await FileSaver.instance.saveFile(
        name: finalFileName,
        bytes: bytes,
        mimeType: MimeType.csv,
      );

      Get.snackbar("Success", "ফাইলটি সফলভাবে ডাউনলোড হয়েছে!", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);

    } catch (e) {
      Get.snackbar("Error", "এক্সপোর্ট করতে সমস্যা হয়েছে: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }
}