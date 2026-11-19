import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/sales_controller.dart';
import '../../models/bike_model.dart';
import '../../models/customer_model.dart';
import '../../models/sale_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../dashboard/custom_sidebar.dart';

class PosSaleScreen extends StatefulWidget {
  const PosSaleScreen({Key? key}) : super(key: key);

  @override
  State<PosSaleScreen> createState() => _PosSaleScreenState();
}

class _PosSaleScreenState extends State<PosSaleScreen> {
  final SalesController salesController = Get.put(SalesController());
  final _formKey = GlobalKey<FormState>();

  BikeModel? selectedBike;
  CustomerModel? selectedCustomer;

  final priceCtrl = TextEditingController();
  final discountCtrl = TextEditingController(text: '0');
  final paidCtrl = TextEditingController();

  double dueAmount = 0.0;

  void _calculateDue() {
    double price = double.tryParse(priceCtrl.text.replaceAll(',', '')) ?? 0;
    double discount = double.tryParse(discountCtrl.text.replaceAll(',', '')) ?? 0;
    double paid = double.tryParse(paidCtrl.text.replaceAll(',', '')) ?? 0;

    setState(() {
      dueAmount = (price - discount) - paid;
    });
  }

  @override
  void initState() {
    super.initState();
    priceCtrl.addListener(_calculateDue);
    discountCtrl.addListener(_calculateDue);
    paidCtrl.addListener(_calculateDue);
  }

  @override
  void dispose() {
    priceCtrl.dispose();
    discountCtrl.dispose();
    paidCtrl.dispose();
    super.dispose();
  }

  void _showAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final bikeDetailsCtrl = TextEditingController();
    final guarantorNameCtrl = TextEditingController();
    final guarantorPhoneCtrl = TextEditingController();
    final securityDetailsCtrl = TextEditingController();
    String selectedSecurityType = 'None';
    final dialogFormKey = GlobalKey<FormState>();
    bool isSaving = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Row(
              children: [
                Icon(Icons.person_add, color: AppColors.primaryBlue),
                SizedBox(width: 10),
                Text(
                  "নতুন কাস্টমার",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Form(
                  key: dialogFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: "কাস্টমারের নাম *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (val) =>
                        (val == null || val.trim().isEmpty) ? "নাম আবশ্যক" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "মোবাইল নম্বর *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (val) =>
                        (val == null || val.trim().isEmpty) ? "নম্বর আবশ্যক" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressCtrl,
                        decoration: InputDecoration(
                          labelText: "ঠিকানা (ঐচ্ছিক)",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: bikeDetailsCtrl,
                        decoration: InputDecoration(
                          labelText: "গাড়ির বিবরণ (ঐচ্ছিক)",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          hintText: "যেমন: Hero Splendor (পুরোনো কাস্টমার হলে)",
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "জামিনদারের তথ্য (Guarantor)",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: guarantorNameCtrl,
                              decoration: InputDecoration(
                                labelText: "জামিনদারের নাম",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: guarantorPhoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "জামিনদারের মোবাইল",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "সিকিউরিটি ডকুমেন্ট (Stamp / Check)",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedSecurityType,
                        decoration: InputDecoration(
                          labelText: "Stamp / Check নির্বাচন করুন",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(value: "None", child: Text("কোনোটি নয় (None)")),
                          DropdownMenuItem(value: "Stamp", child: Text("স্ট্যাম্প (Stamp)")),
                          DropdownMenuItem(value: "Check", child: Text("চেক (Check)")),
                          DropdownMenuItem(
                            value: "Both (Stamp & Check)",
                            child: Text("স্ট্যাম্প ও চেক উভয়ই (Both)"),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedSecurityType = val);
                          }
                        },
                      ),
                      if (selectedSecurityType != 'None') ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: securityDetailsCtrl,
                          decoration: InputDecoration(
                            labelText: "$selectedSecurityType এর নম্বর / ব্যাংক / বিবরণ",
                            hintText: "যেমন: DBBL Check #44512 / 300 Tk Stamp",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("বাতিল", style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                  if (dialogFormKey.currentState!.validate()) {
                    setDialogState(() => isSaving = true);
                    try {
                      final addedPhone = phoneCtrl.text.trim();

                      await FirebaseFirestore.instance.collection('customers').add({
                        'name': nameCtrl.text.trim(),
                        'phone': addedPhone,
                        'address': addressCtrl.text.trim(),
                        'bikeDetails': bikeDetailsCtrl.text.trim(),
                        'guarantorName': guarantorNameCtrl.text.trim(),
                        'guarantorPhone': guarantorPhoneCtrl.text.trim(),
                        'securityType': selectedSecurityType,
                        'securityDetails': selectedSecurityType == 'None'
                            ? ''
                            : securityDetailsCtrl.text.trim(),
                        'totalDue': 0.0,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      Get.back();
                      Get.snackbar(
                        "Success",
                        "কাস্টমার সফলভাবে যুক্ত হয়েছে!",
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );

                      Future.delayed(const Duration(milliseconds: 600), () {
                        try {
                          final newlyAdded = salesController.customers
                              .firstWhere((c) => c.phone == addedPhone);
                          setState(() {
                            selectedCustomer = newlyAdded;
                          });
                        } catch (e) {
                          debugPrint("Auto select failed: $e");
                        }
                      });
                    } catch (e) {
                      Get.snackbar(
                        "Error",
                        "কাস্টমার সেভ করতে সমস্যা হয়েছে।",
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
                    setDialogState(() => isSaving = false);
                  }
                },
                child: isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text("সেভ করুন", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: isMobile
          ? AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text("POS / Sell", style: TextStyle(color: AppColors.pureWhite)),
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
        elevation: 0,
      )
          : null,
      drawer: isMobile ? CustomSidebar(isMobile: true) : null,

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) CustomSidebar(isMobile: false),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Center(
                  child: Container(
                    width: isMobile ? double.infinity : 900,
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(35.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.point_of_sale, color: AppColors.primaryBlue, size: 32),
                                SizedBox(width: 15),
                                Text("New Sale Entry", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.solidBlack)),
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Divider(color: Colors.black12),
                            const SizedBox(height: 25),

                            Flex(
                              direction: isMobile ? Axis.vertical : Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // কাস্টমার সিলেক্ট + অ্যাড বাটন
                                Expanded(
                                  flex: isMobile ? 0 : 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("1. Select Customer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textGray)),
                                          InkWell(
                                            onTap: _showAddCustomerDialog, // নতুন কাস্টমার অ্যাড করার ডায়ালগ ওপেন হবে
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.add, size: 16, color: AppColors.primaryBlue),
                                                  Text(" New", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Obx(() => DropdownButtonFormField<CustomerModel>(
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.person, color: AppColors.accentBlue),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        hint: const Text("কাস্টমার খুঁজুন..."),
                                        value: selectedCustomer,
                                        items: salesController.customers.map((customer) {
                                          return DropdownMenuItem(value: customer, child: Text("${customer.name} (${customer.phone})"));
                                        }).toList(),
                                        onChanged: (val) => setState(() => selectedCustomer = val),
                                        validator: (value) => value == null ? "কাস্টমার সিলেক্ট করুন" : null,
                                      )),
                                    ],
                                  ),
                                ),
                                if (!isMobile) const SizedBox(width: 30),
                                if (isMobile) const SizedBox(height: 25),

                                // বাইক সিলেক্ট
                                Expanded(
                                  flex: isMobile ? 0 : 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("2. Select Bike", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textGray)),
                                      const SizedBox(height: 10),
                                      Obx(() => DropdownButtonFormField<BikeModel>(
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.motorcycle, color: AppColors.accentBlue),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        hint: const Text("স্টক থেকে বাইক সিলেক্ট করুন..."),
                                        value: selectedBike,
                                        items: salesController.availableBikes.map((bike) {
                                          return DropdownMenuItem(value: bike, child: Text("${bike.brand} ${bike.model} - ${bike.chassisNo}"));
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            selectedBike = val;
                                            priceCtrl.text = val?.purchasePrice.toInt().toString() ?? '0';
                                          });
                                        },
                                        validator: (value) => value == null ? "বাইক সিলেক্ট করুন" : null,
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (selectedBike != null) ...[
                              const SizedBox(height: 25),
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withOpacity(0.2))),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80, height: 80,
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: selectedBike!.imageUrl != null && selectedBike!.imageUrl!.isNotEmpty
                                            ? Image.network(selectedBike!.imageUrl!, fit: BoxFit.cover)
                                            : const Icon(Icons.two_wheeler, size: 40, color: Colors.black26),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("${selectedBike!.brand} ${selectedBike!.model}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.solidBlack)),
                                          const SizedBox(height: 5),
                                          Text("Chassis: ${selectedBike!.chassisNo}  |  Color: ${selectedBike!.color}", style: const TextStyle(color: AppColors.textGray)),
                                          Text("Purchase Price: ৳${selectedBike!.purchasePrice.toInt()}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 40),
                            const Text("3. Payment Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.solidBlack)),
                            const Divider(color: Colors.black12),
                            const SizedBox(height: 20),

                            Flex(
                              direction: isMobile ? Axis.vertical : Axis.horizontal,
                              children: [
                                Expanded(flex: isMobile ? 0 : 1, child: _buildTextField("Selling Price (৳)", priceCtrl, Icons.sell)),
                                if (!isMobile) const SizedBox(width: 20),
                                if (isMobile) const SizedBox(height: 20),
                                Expanded(flex: isMobile ? 0 : 1, child: _buildTextField("Discount (৳)", discountCtrl, Icons.local_offer)),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Flex(
                              direction: isMobile ? Axis.vertical : Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: isMobile ? 0 : 1, child: _buildTextField("Paid Amount (৳)", paidCtrl, Icons.payments, isAction: true)),
                                if (!isMobile) const SizedBox(width: 20),
                                if (isMobile) const SizedBox(height: 20),

                                Expanded(
                                  flex: isMobile ? 0 : 1,
                                  child: Container(
                                    height: 55,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: dueAmount > 0 ? Colors.redAccent.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: dueAmount > 0 ? Colors.redAccent.withOpacity(0.5) : Colors.green.withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Due Amount:", style: TextStyle(color: dueAmount > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "৳ ${dueAmount.toInt()}",
                                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: dueAmount > 0 ? Colors.red : Colors.green),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            Obx(() => SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.solidBlack,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 5,
                                ),
                                onPressed: salesController.isLoading.value ? null : _submitSale,
                                icon: salesController.isLoading.value
                                    ? const SizedBox.shrink()
                                    : const Icon(Icons.check_circle, color: AppColors.pureWhite, size: 28),
                                label: salesController.isLoading.value
                                    ? const CircularProgressIndicator(color: AppColors.pureWhite)
                                    : const Text("CONFIRM SALE", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.pureWhite, letterSpacing: 1.5)),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isAction = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: isAction ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGray),
        prefixIcon: Icon(icon, color: AppColors.accentBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2), borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
      validator: (value) => value!.isEmpty ? "Required" : null,
    );
  }

  void _submitSale() {
    if (_formKey.currentState!.validate()) {
      if (selectedBike == null || selectedCustomer == null) {
        Get.snackbar("Warning", "Please select both Customer and Bike.", backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      double parsedPrice = double.tryParse(priceCtrl.text.replaceAll(',', '')) ?? 0.0;
      double parsedDiscount = double.tryParse(discountCtrl.text.replaceAll(',', '')) ?? 0.0;
      double parsedPaid = double.tryParse(paidCtrl.text.replaceAll(',', '')) ?? 0.0;

      SaleModel newSale = SaleModel(
        bikeId: selectedBike!.id!,
        bikeDetails: "${selectedBike!.brand} ${selectedBike!.model} (Chassis: ${selectedBike!.chassisNo})",
        customerId: selectedCustomer!.id!,
        customerName: selectedCustomer!.name,
        salePrice: parsedPrice,
        discount: parsedDiscount,
        paidAmount: parsedPaid,
        dueAmount: dueAmount,
        saleDate: DateTime.now(),
      );

      salesController.processSale(newSale);
    }
  }
}