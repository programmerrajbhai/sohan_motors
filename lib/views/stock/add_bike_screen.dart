import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/stock_controller.dart';
import '../../models/bike_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../dashboard/custom_sidebar.dart';

class AddBikeScreen extends StatefulWidget {
  final BikeModel? existingBike;

  const AddBikeScreen({Key? key, this.existingBike}) : super(key: key);

  @override
  State<AddBikeScreen> createState() => _AddBikeScreenState();
}

class _AddBikeScreenState extends State<AddBikeScreen> {
  final StockController stockController = Get.put(StockController());
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController brandCtrl;
  late final TextEditingController modelCtrl;
  late final TextEditingController colorCtrl;
  late final TextEditingController regCtrl;
  late final TextEditingController chassisCtrl;
  late final TextEditingController engineCtrl;
  late final TextEditingController buyPriceCtrl;
  late final TextEditingController sellPriceCtrl;

  String imageUrl = '';
  String selectedStatus = 'Available';
  Uint8List? selectedImageBytes;

  bool get isEditing => widget.existingBike != null;

  @override
  void initState() {
    super.initState();
    final bike = widget.existingBike;
    brandCtrl = TextEditingController(text: bike?.brand ?? '');
    modelCtrl = TextEditingController(text: bike?.model ?? '');
    colorCtrl = TextEditingController(text: bike?.color ?? '');
    regCtrl = TextEditingController(
      text: (bike == null || bike.registration.isEmpty)
          ? 'Unregistered'
          : bike.registration,
    );
    chassisCtrl = TextEditingController(text: bike?.chassisNo ?? '');
    engineCtrl = TextEditingController(text: bike?.engineNo ?? '');
    buyPriceCtrl = TextEditingController(
      text: (bike != null && bike.purchasePrice > 0)
          ? bike.purchasePrice.toInt().toString()
          : '',
    );
    sellPriceCtrl = TextEditingController(
      text: (bike != null && bike.sellingPrice > 0)
          ? bike.sellingPrice.toInt().toString()
          : '',
    );
    imageUrl = bike?.imageUrl ?? '';
    selectedStatus = bike?.status ?? 'Available';
  }

  @override
  void dispose() {
    brandCtrl.dispose();
    modelCtrl.dispose();
    colorCtrl.dispose();
    regCtrl.dispose();
    chassisCtrl.dispose();
    engineCtrl.dispose();
    buyPriceCtrl.dispose();
    sellPriceCtrl.dispose();
    super.dispose();
  }

  double get _buyPrice => double.tryParse(buyPriceCtrl.text.trim()) ?? 0.0;
  double get _sellPrice => double.tryParse(sellPriceCtrl.text.trim()) ?? 0.0;
  double get _liveProfit => _sellPrice - _buyPrice;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      selectedImageBytes = bytes;
    });

    final uploadedUrl = await stockController.uploadImageToImgBB(
      bytes,
      picked.name,
    );
    if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
      setState(() {
        imageUrl = uploadedUrl;
      });
      Get.snackbar(
        "Uploaded",
        "বাইকের ছবি সফলভাবে আপলোড হয়েছে!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _saveBike() async {
    if (!_formKey.currentState!.validate()) return;

    final double parsedBuy = double.parse(buyPriceCtrl.text.trim());
    final double parsedSell = double.parse(sellPriceCtrl.text.trim());
    final String regValue =
    regCtrl.text.trim().isEmpty ? 'Unregistered' : regCtrl.text.trim();

    if (isEditing) {
      final updatedBike = BikeModel(
        id: widget.existingBike!.id,
        brand: brandCtrl.text.trim(),
        model: modelCtrl.text.trim(),
        color: colorCtrl.text.trim(),
        registration: regValue,
        chassisNo: chassisCtrl.text.trim(),
        engineNo: engineCtrl.text.trim(),
        purchasePrice: parsedBuy,
        sellingPrice: parsedSell,
        status: selectedStatus,
        imageUrl: imageUrl,
        createdAt: widget.existingBike!.createdAt,
      );
      await stockController.updateBike(updatedBike);
    } else {
      final newBike = BikeModel(
        brand: brandCtrl.text.trim(),
        model: modelCtrl.text.trim(),
        color: colorCtrl.text.trim(),
        registration: regValue,
        chassisNo: chassisCtrl.text.trim(),
        engineNo: engineCtrl.text.trim(),
        purchasePrice: parsedBuy,
        sellingPrice: parsedSell,
        status: 'Available',
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );
      await stockController.addBike(newBike);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: isMobile
          ? AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          isEditing ? "Edit Bike" : "Add New Bike",
          style: const TextStyle(color: AppColors.pureWhite),
        ),
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
        elevation: 0,
      )
          : null,
      drawer: isMobile ? const CustomSidebar(isMobile: true) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) const CustomSidebar(isMobile: false),
          Expanded(
            child: Column(
              children: [
                if (!isMobile)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    decoration: const BoxDecoration(
                      color: AppColors.pureWhite,
                      border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back, color: AppColors.solidBlack),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? "Edit Bike Details" : "Add New Bike to Stock",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.solidBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 16 : 28),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 820),
                        padding: EdgeInsets.all(isMobile ? 18 : 28),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.two_wheeler, color: AppColors.primaryBlue, size: 26),
                                  SizedBox(width: 10),
                                  Text(
                                    "বাইকের বিস্তারিত তথ্য ও মূল্য নির্ধারণ",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.solidBlack,
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Divider(color: Colors.black12, height: 1),
                              ),

                              // ১. ব্র্যান্ড ও মডেল
                              _buildResponsivePair(
                                isMobile: isMobile,
                                first: TextFormField(
                                  controller: brandCtrl,
                                  decoration: _inputDecoration("ব্র্যান্ড (Brand) *", "যেমন: Yamaha, Honda, Bajaj", Icons.branding_watermark),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? "ব্র্যান্ড আবশ্যক" : null,
                                ),
                                second: TextFormField(
                                  controller: modelCtrl,
                                  decoration: _inputDecoration("মডেল (Model) *", "যেমন: R15 V3, Pulsar 150", Icons.motorcycle),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? "মডেল আবশ্যক" : null,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ২. রঙের ঠিক পাশেই রেজিস্ট্রেশন (Color + Registration)
                              _buildResponsivePair(
                                isMobile: isMobile,
                                first: TextFormField(
                                  controller: colorCtrl,
                                  decoration: _inputDecoration("রঙ (Color) *", "যেমন: Black, Red, Blue", Icons.palette),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? "রঙ আবশ্যক" : null,
                                ),
                                second: TextFormField(
                                  controller: regCtrl,
                                  decoration: _inputDecoration(
                                    "রেজিস্ট্রেশন (Registration)",
                                    "Unregistered অথবা Dhaka Metro-La...",
                                    Icons.app_registration,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ৩. চেসিস ও ইঞ্জিন নম্বর
                              _buildResponsivePair(
                                isMobile: isMobile,
                                first: TextFormField(
                                  controller: chassisCtrl,
                                  decoration: _inputDecoration("চেসিস নম্বর (Chassis No) *", "চেসিস নম্বর লিখুন", Icons.confirmation_number),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? "চেসিস নম্বর আবশ্যক" : null,
                                ),
                                second: TextFormField(
                                  controller: engineCtrl,
                                  decoration: _inputDecoration("ইঞ্জিন নম্বর (Engine No) *", "ইঞ্জিন নম্বর লিখুন", Icons.settings),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? "ইঞ্জিন নম্বর আবশ্যক" : null,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ৪. কেনার দাম (Buy Price) এবং বিক্রির দাম (Sell Price)
                              const Text(
                                "দাম ও লাভের হিসাব (Pricing & Profit)",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildResponsivePair(
                                isMobile: isMobile,
                                first: TextFormField(
                                  controller: buyPriceCtrl,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: _inputDecoration("কেনার দাম (Buy Price) *", "0", Icons.shopping_bag, prefixText: "৳ "),
                                  validator: (v) {
                                    final d = double.tryParse(v?.trim() ?? '');
                                    if (d == null || d < 0) return "সঠিক কেনার দাম দিন";
                                    return null;
                                  },
                                ),
                                second: TextFormField(
                                  controller: sellPriceCtrl,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: _inputDecoration("বিক্রির দাম (Sell Price) *", "0", Icons.sell, prefixText: "৳ "),
                                  validator: (v) {
                                    final d = double.tryParse(v?.trim() ?? '');
                                    if (d == null || d < 0) return "সঠিক বিক্রির দাম দিন";
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ৫. লাইভ প্রফিট/লস বক্স
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _liveProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _liveProfit >= 0 ? Colors.green.shade300 : Colors.red.shade300,
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _liveProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                                          color: _liveProfit >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          _liveProfit >= 0
                                              ? "আনুমানিক লাভ (Estimated Profit):"
                                              : "আনুমানিক ক্ষতি (Estimated Loss):",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: _liveProfit >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${_liveProfit >= 0 ? '+' : '-'}৳${_liveProfit.abs().toInt()}",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: _liveProfit >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (isEditing) ...[
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: selectedStatus,
                                  decoration: _inputDecoration("স্টক স্ট্যাটাস", "", Icons.info_outline),
                                  items: const [
                                    DropdownMenuItem(value: "Available", child: Text("Available")),
                                    DropdownMenuItem(value: "Sold", child: Text("Sold")),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => selectedStatus = val);
                                  },
                                ),
                              ],

                              const SizedBox(height: 20),

                              // ৬. বাইকের ছবি আপলোড সেকশন
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: selectedImageBytes != null
                                            ? Image.memory(selectedImageBytes!, fit: BoxFit.cover)
                                            : (imageUrl.isNotEmpty
                                            ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.two_wheeler,
                                            size: 36,
                                            color: AppColors.primaryBlue,
                                          ),
                                        )
                                            : const Icon(
                                          Icons.two_wheeler,
                                          size: 36,
                                          color: AppColors.primaryBlue,
                                        )),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "বাইকের ছবি (ঐচ্ছিক)",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            imageUrl.isNotEmpty
                                                ? "ছবি সফলভাবে যুক্ত হয়েছে ✓"
                                                : "গ্যালারি থেকে বাইকের ছবি সিলেক্ট করুন",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: imageUrl.isNotEmpty ? Colors.green : AppColors.textGray,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Obx(
                                                () => ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primaryBlue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: stockController.isUploadingImage.value
                                                  ? null
                                                  : _pickAndUploadImage,
                                              icon: const Icon(Icons.upload, color: Colors.white, size: 18),
                                              label: Text(
                                                stockController.isUploadingImage.value
                                                    ? "Uploading..."
                                                    : "ছবি সিলেক্ট করুন",
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 26),

                              // ৭. সেভ ও বাতিল বাটন
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => Get.back(),
                                    child: const Text("বাতিল", style: TextStyle(color: Colors.red)),
                                  ),
                                  const SizedBox(width: 14),
                                  Obx(
                                        () => ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: stockController.isLoading.value ? null : _saveBike,
                                      icon: stockController.isLoading.value
                                          ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                          : const Icon(Icons.check_circle, color: Colors.white),
                                      label: Text(
                                        isEditing ? "আপডেট করুন" : "স্টকে সেভ করুন",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsivePair({
    required bool isMobile,
    required Widget first,
    required Widget second,
  }) {
    if (isMobile) {
      return Column(
        children: [
          first,
          const SizedBox(height: 14),
          second,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 16),
        Expanded(child: second),
      ],
    );
  }

  InputDecoration _inputDecoration(
      String label,
      String hint,
      IconData icon, {
        String? prefixText,
      }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    );
  }
}