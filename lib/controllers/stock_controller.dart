import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/bike_model.dart';

class StockController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var bikeList = <BikeModel>[].obs;
  var isLoading = false.obs;
  var isUploadingImage = false.obs;

  // প্রয়োজন হলে আপনার ImgBB API Key এখানে দিন
  static const String _imgBbApiKey = '';

  @override
  void onInit() {
    super.onInit();
    fetchBikes();
  }

  void fetchBikes() {
    _firestore
        .collection('bikes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      try {
        bikeList.value =
            snapshot.docs.map((doc) => BikeModel.fromFirestore(doc)).toList();
      } catch (e) {
        debugPrint("Bike parse error: $e");
      }
    });
  }

  Future<String?> uploadImageToImgBB(Uint8List bytes, String fileName) async {
    if (_imgBbApiKey.isEmpty) {
      Get.snackbar(
        "Info",
        "ImgBB API Key সেট করা নেই; ছবি ছাড়াই বাইক সেভ করতে পারবেন।",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return null;
    }

    try {
      isUploadingImage(true);
      final uri = Uri.parse("https://api.imgbb.com/1/upload?key=$_imgBbApiKey");
      final response = await http.post(
        uri,
        body: {
          'image': base64Encode(bytes),
          'name': fileName,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data']?['url']?.toString();
      }
      return null;
    } catch (e) {
      debugPrint("Image upload error: $e");
      return null;
    } finally {
      isUploadingImage(false);
    }
  }

  Future<void> addBike(BikeModel bike) async {
    try {
      isLoading(true);
      await _firestore.collection('bikes').add(bike.toMap(useServerTimestamp: true));
      Get.back();
      Get.snackbar(
        "Success",
        "বাইকটি সফলভাবে স্টকে যুক্ত হয়েছে!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "বাইক সেভ করতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateBike(BikeModel bike) async {
    if (bike.id == null) return;
    try {
      isLoading(true);
      await _firestore.collection('bikes').doc(bike.id).update({
        'brand': bike.brand,
        'model': bike.model,
        'color': bike.color,
        'registration': bike.registration.trim().isEmpty ? 'Unregistered' : bike.registration.trim(),
        'chassisNo': bike.chassisNo,
        'engineNo': bike.engineNo,
        'purchasePrice': bike.purchasePrice,
        'sellingPrice': bike.sellingPrice,
        'estimatedProfit': bike.estimatedProfit,
        'status': bike.status,
        'imageUrl': bike.imageUrl,
      });
      Get.back();
      Get.snackbar(
        "Updated",
        "বাইকের তথ্য ও লাভের হিসাব আপডেট হয়েছে!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "আপডেট করতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteBike(String bikeId) async {
    try {
      await _firestore.collection('bikes').doc(bikeId).delete();
      Get.snackbar(
        "Deleted",
        "বাইকটি স্টক থেকে মুছে ফেলা হয়েছে।",
        backgroundColor: Colors.redAccent,
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