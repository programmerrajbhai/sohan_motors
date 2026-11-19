import 'package:cloud_firestore/cloud_firestore.dart';

class BikeModel {
  String? id;
  String brand;
  String model;
  String color;
  String registration; // রঙের পাশে রেজিস্ট্রেশন (যেমন: Unregistered / Reg No)
  String chassisNo;
  String engineNo;
  double purchasePrice; // কেনার দাম (Buy Price)
  double sellingPrice; // বিক্রির দাম (Sell Price)
  String status; // Available / Sold
  String imageUrl;
  DateTime createdAt;

  BikeModel({
    this.id,
    required this.brand,
    required this.model,
    required this.color,
    this.registration = 'Unregistered',
    required this.chassisNo,
    required this.engineNo,
    required this.purchasePrice,
    this.sellingPrice = 0.0,
    this.status = 'Available',
    this.imageUrl = '',
    required this.createdAt,
  });

  double get estimatedProfit => sellingPrice - purchasePrice;

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  factory BikeModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    final regText = data['registration']?.toString().trim();
    return BikeModel(
      id: doc.id,
      brand: data['brand']?.toString() ?? '',
      model: data['model']?.toString() ?? '',
      color: data['color']?.toString() ?? '',
      registration: (regText == null || regText.isEmpty) ? 'Unregistered' : regText,
      chassisNo: data['chassisNo']?.toString() ?? '',
      engineNo: data['engineNo']?.toString() ?? '',
      purchasePrice: _toDouble(data['purchasePrice']),
      sellingPrice: _toDouble(data['sellingPrice']),
      status: data['status']?.toString() ?? 'Available',
      imageUrl: data['imageUrl']?.toString() ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap({bool useServerTimestamp = true}) {
    return {
      'brand': brand,
      'model': model,
      'color': color,
      'registration': registration.trim().isEmpty ? 'Unregistered' : registration.trim(),
      'chassisNo': chassisNo,
      'engineNo': engineNo,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'estimatedProfit': estimatedProfit,
      'status': status,
      'imageUrl': imageUrl,
      'createdAt': useServerTimestamp ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt),
    };
  }
}