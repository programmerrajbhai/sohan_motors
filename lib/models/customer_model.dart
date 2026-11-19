import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  String? id;
  String name;
  String phone;
  String address;
  String bikeDetails;
  String guarantorName;
  String guarantorPhone;
  String securityType;
  String securityDetails;
  String installmentComment; // কয়টা কিস্তি আছে/নেই বা তারিখের কমেন্ট
  double totalDue;
  DateTime? nextInstallmentDate;
  DateTime createdAt;

  CustomerModel({
    this.id,
    required this.name,
    required this.phone,
    this.address = '',
    this.bikeDetails = '',
    this.guarantorName = '',
    this.guarantorPhone = '',
    this.securityType = 'None',
    this.securityDetails = '',
    this.installmentComment = '',
    this.totalDue = 0.0,
    this.nextInstallmentDate,
    required this.createdAt,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    final secType = data['securityType']?.toString().trim();
    final commentText = (data['installmentComment'] ?? data['comment'])?.toString() ?? '';

    return CustomerModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      bikeDetails: data['bikeDetails']?.toString() ?? '',
      guarantorName: data['guarantorName']?.toString() ?? '',
      guarantorPhone: data['guarantorPhone']?.toString() ?? '',
      securityType: (secType == null || secType.isEmpty) ? 'None' : secType,
      securityDetails: data['securityDetails']?.toString() ?? '',
      installmentComment: commentText,
      totalDue: _toDouble(data['totalDue']),
      nextInstallmentDate: data['nextInstallmentDate'] is Timestamp
          ? (data['nextInstallmentDate'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'bikeDetails': bikeDetails,
      'guarantorName': guarantorName,
      'guarantorPhone': guarantorPhone,
      'securityType': securityType,
      'securityDetails': securityDetails,
      'installmentComment': installmentComment,
      'comment': installmentComment,
      'totalDue': totalDue,
      'nextInstallmentDate': nextInstallmentDate,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}