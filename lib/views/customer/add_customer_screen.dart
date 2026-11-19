import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../models/customer_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';


class AddCustomerScreen extends StatelessWidget {
  AddCustomerScreen({Key? key}) : super(key: key);

  final CustomerController customerController = Get.put(CustomerController());
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text("নতুন কাস্টমার এন্ট্রি", style: TextStyle(color: AppColors.pureWhite)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: isMobile ? double.infinity : 600,
            padding: const EdgeInsets.all(20),
            child: Card(
              color: AppColors.pureWhite,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const Text("কাস্টমারের তথ্য দিন", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.solidBlack)),
                      const Divider(),
                      const SizedBox(height: 20),
          
                      _buildTextField("নাম (Name)", nameCtrl, Icons.person),
                      const SizedBox(height: 15),
          
                      _buildTextField("মোবাইল নম্বর", phoneCtrl, Icons.phone_android, isNumber: true),
                      const SizedBox(height: 15),
          
                      _buildTextField("ঠিকানা (Address)", addressCtrl, Icons.location_on),
                      const SizedBox(height: 30),
          
                      Obx(() => SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: customerController.isLoading.value ? null : () => _saveCustomer(),
                          child: customerController.isLoading.value
                              ? const CircularProgressIndicator(color: AppColors.pureWhite)
                              : const Text("SAVE CUSTOMER", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.pureWhite)),
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
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.accentBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2), borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value!.isEmpty ? "এই ঘরটি পূরণ করুন" : null,
    );
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      CustomerModel newCustomer = CustomerModel(
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        address: addressCtrl.text,
        createdAt: DateTime.now(),
      );
      customerController.addCustomer(newCustomer);
    }
  }
}