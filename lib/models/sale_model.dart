import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel {
  String? id;
  String bikeId;
  String bikeDetails; // কোন বাইক (ব্র্যান্ড + মডেল + চেসিস)
  String customerId;
  String customerName;
  double salePrice; // কত দামে বিক্রি হলো
  double discount; // কত টাকা ছাড়
  double paidAmount; // কত টাকা নগদ দিল
  double dueAmount; // কত বকেয়া থাকল
  DateTime saleDate;

  SaleModel({
    this.id,
    required this.bikeId,
    required this.bikeDetails,
    required this.customerId,
    required this.customerName,
    required this.salePrice,
    this.discount = 0.0,
    required this.paidAmount,
    required this.dueAmount,
    required this.saleDate,
  });

  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SaleModel(
      id: doc.id,
      bikeId: data['bikeId'] ?? '',
      bikeDetails: data['bikeDetails'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      salePrice: (data['salePrice'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      paidAmount: (data['paidAmount'] ?? 0).toDouble(),
      dueAmount: (data['dueAmount'] ?? 0).toDouble(),
      saleDate: (data['saleDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bikeId': bikeId,
      'bikeDetails': bikeDetails,
      'customerId': customerId,
      'customerName': customerName,
      'salePrice': salePrice,
      'discount': discount,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'saleDate': FieldValue.serverTimestamp(),
    };
  }
}