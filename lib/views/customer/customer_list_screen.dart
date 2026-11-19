import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../models/customer_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../dashboard/custom_sidebar.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final CustomerController customerController = Get.put(CustomerController());
  final TextEditingController searchCtrl = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  bool _matchesSearch(CustomerModel c) {
    if (searchQuery.trim().isEmpty) return true;
    final q = searchQuery.trim().toLowerCase();
    return c.name.toLowerCase().contains(q) ||
        c.phone.toLowerCase().contains(q) ||
        c.address.toLowerCase().contains(q) ||
        c.bikeDetails.toLowerCase().contains(q) ||
        c.guarantorName.toLowerCase().contains(q) ||
        c.guarantorPhone.toLowerCase().contains(q) ||
        c.securityType.toLowerCase().contains(q) ||
        c.securityDetails.toLowerCase().contains(q) ||
        c.installmentComment.toLowerCase().contains(q);
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: isMobile
          ? AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          "Customers",
          style: TextStyle(color: AppColors.pureWhite),
        ),
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
        elevation: 0,
      )
          : null,
      drawer: isMobile ? const CustomSidebar(isMobile: true) : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomerFormDialog(context),
        backgroundColor: AppColors.solidBlack,
        icon: const Icon(Icons.person_add, color: AppColors.pureWhite),
        label: const Text(
          "নতুন কাস্টমার",
          style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold),
        ),
      ),
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
                      border: Border(
                        bottom: BorderSide(color: Colors.black12, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Manage Customers",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.solidBlack,
                          ),
                        ),
                        Container(
                          width: 320,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: TextField(
                            controller: searchCtrl,
                            onChanged: (val) => setState(() => searchQuery = val),
                            decoration: const InputDecoration(
                              hintText: "Search customer, guarantor, check...",
                              prefixIcon: Icon(Icons.search, color: AppColors.textGray),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Obx(() {
                    final List<CustomerModel> allCustomers =
                    customerController.customerList.cast<CustomerModel>();
                    final filteredCustomers =
                    allCustomers.where(_matchesSearch).toList();

                    if (filteredCustomers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 15),
                            const Text(
                              "কোনো কাস্টমার পাওয়া যায়নি।",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.solidBlack,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          if (isMobile) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: TextField(
                                controller: searchCtrl,
                                onChanged: (val) => setState(() => searchQuery = val),
                                decoration: const InputDecoration(
                                  hintText: "Search customer, guarantor, check...",
                                  prefixIcon: Icon(Icons.search, color: AppColors.textGray),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                ),
                              ),
                            ),
                          ],
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 430,
                              mainAxisExtent: 300,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                            itemCount: filteredCustomers.length,
                            itemBuilder: (context, index) =>
                                _buildCustomerCard(context, filteredCustomers[index]),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerModel customer) {
    final bool hasGuarantor = customer.guarantorName.trim().isNotEmpty ||
        customer.guarantorPhone.trim().isNotEmpty;
    final bool hasSecurity = customer.securityType != 'None' ||
        customer.securityDetails.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.solidBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        customer.phone,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit & Delete বাটন
                IconButton(
                  tooltip: "Edit Customer",
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      _showCustomerFormDialog(context, existingCustomer: customer),
                  icon: const Icon(Icons.edit, color: AppColors.primaryBlue, size: 20),
                ),
                IconButton(
                  tooltip: "Delete Customer",
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showDeleteConfirmDialog(customer),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Colors.black12, height: 1),
            ),
            _buildInfoRow(
              Icons.location_on,
              customer.address.isEmpty ? "ঠিকানা দেওয়া নেই" : customer.address,
            ),
            const SizedBox(height: 5),
            _buildInfoRow(
              Icons.two_wheeler,
              customer.bikeDetails.isEmpty ? "গাড়ির বিবরণ নেই" : customer.bikeDetails,
            ),
            const SizedBox(height: 5),
            _buildInfoRow(
              Icons.verified_user,
              hasGuarantor
                  ? "জামিনদার: ${customer.guarantorName.isEmpty ? 'N/A' : customer.guarantorName}${customer.guarantorPhone.isNotEmpty ? ' (${customer.guarantorPhone})' : ''}"
                  : "জামিনদার: যুক্ত করা নেই",
            ),
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: hasSecurity
                    ? Colors.amber.withOpacity(0.14)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasSecurity ? Colors.amber.shade400 : Colors.black12,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 15,
                    color: hasSecurity ? Colors.amber.shade900 : AppColors.textGray,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hasSecurity
                          ? "${customer.securityType}${customer.securityDetails.isNotEmpty ? ': ${customer.securityDetails}' : ''}"
                          : "Stamp / Check: নেই",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: hasSecurity ? Colors.amber.shade900 : AppColors.textGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (customer.installmentComment.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                "Note: ${customer.installmentComment}",
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: customer.totalDue > 0
                    ? Colors.redAccent.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    customer.totalDue > 0 ? "Total Due:" : "No Due",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: customer.totalDue > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                  if (customer.totalDue > 0)
                    Text(
                      "৳${customer.totalDue.toInt()}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textGray),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: AppColors.solidBlack),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(CustomerModel customer) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text(
              "কাস্টমার ডিলিট করবেন?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          "আপনি কি নিশ্চিতভাবে '${customer.name}' (${customer.phone}) কাস্টমারটিকে ডিলিট করতে চান? এই তথ্যটি মুছে গেলে আর ফেরত আনা যাবে না।",
          style: const TextStyle(fontSize: 14, color: AppColors.solidBlack),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("বাতিল", style: TextStyle(color: AppColors.textGray)),
          ),
          Obx(
                () => ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: customerController.isLoading.value || customer.id == null
                  ? null
                  : () => customerController.deleteCustomer(customer.id!),
              icon: const Icon(Icons.delete, color: Colors.white, size: 18),
              label: const Text(
                "ডিলিট করুন",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerFormDialog(
      BuildContext context, {
        CustomerModel? existingCustomer,
      }) {
    final bool isEditing = existingCustomer != null;
    final formKey = GlobalKey<FormState>();

    final nameCtrl = TextEditingController(text: existingCustomer?.name ?? '');
    final phoneCtrl = TextEditingController(text: existingCustomer?.phone ?? '');
    final addressCtrl = TextEditingController(text: existingCustomer?.address ?? '');
    final bikeDetailsCtrl =
    TextEditingController(text: existingCustomer?.bikeDetails ?? '');
    final guarantorNameCtrl =
    TextEditingController(text: existingCustomer?.guarantorName ?? '');
    final guarantorPhoneCtrl =
    TextEditingController(text: existingCustomer?.guarantorPhone ?? '');
    final securityDetailsCtrl =
    TextEditingController(text: existingCustomer?.securityDetails ?? '');
    final commentCtrl =
    TextEditingController(text: existingCustomer?.installmentComment ?? '');
    final dueCtrl = TextEditingController(
      text: existingCustomer != null && existingCustomer.totalDue > 0
          ? existingCustomer.totalDue.toInt().toString()
          : '0',
    );

    String selectedSecurityType = existingCustomer?.securityType ?? 'None';
    const allowedTypes = [
      'None',
      'Stamp',
      'Check',
      'Both (Stamp & Check)',
    ];
    if (!allowedTypes.contains(selectedSecurityType)) {
      selectedSecurityType = 'None';
    }

    DateTime? selectedNextDate = existingCustomer?.nextInstallmentDate;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                Icon(
                  isEditing ? Icons.edit : Icons.person_add,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 10),
                Text(
                  isEditing ? "কাস্টমার তথ্য এডিট করুন" : "নতুন কাস্টমার",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
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
                          labelText: "গাড়ির বিবরণ / মডেল (ঐচ্ছিক)",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          hintText: "যেমন: Hero Splendor, Chassis: 123",
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
                      if (isEditing) ...[
                        const SizedBox(height: 16),
                        const Text(
                          "বকেয়া ও কিস্তির তথ্য (Edit)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: dueCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "মোট বকেয়া (Total Due ৳)",
                            prefixText: "৳ ",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) {
                            final d = double.tryParse(val?.trim() ?? '');
                            if (d == null || d < 0) return "সঠিক বকেয়ার পরিমাণ দিন";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedNextDate ??
                                  DateTime.now().add(const Duration(days: 30)),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              setDialogState(() => selectedNextDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedNextDate != null
                                      ? "কিস্তির তারিখ: ${_formatDate(selectedNextDate!)}"
                                      : "কিস্তির তারিখ সেট করুন (ঐচ্ছিক)",
                                ),
                                Row(
                                  children: [
                                    if (selectedNextDate != null)
                                      InkWell(
                                        onTap: () => setDialogState(() => selectedNextDate = null),
                                        child: const Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: Icon(Icons.clear, color: Colors.red, size: 18),
                                        ),
                                      ),
                                    const Icon(Icons.calendar_month, color: AppColors.primaryBlue),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: commentCtrl,
                          decoration: InputDecoration(
                            labelText: "কিস্তির কমেন্ট / নোট",
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
              Obx(
                    () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: customerController.isLoading.value
                      ? null
                      : () {
                    if (formKey.currentState!.validate()) {
                      final String cleanSecurityDetails =
                      selectedSecurityType == 'None'
                          ? ''
                          : securityDetailsCtrl.text.trim();

                      if (isEditing) {
                        final double parsedDue =
                            double.tryParse(dueCtrl.text.trim()) ?? 0.0;
                        final updatedCustomer = CustomerModel(
                          id: existingCustomer.id,
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          address: addressCtrl.text.trim(),
                          bikeDetails: bikeDetailsCtrl.text.trim(),
                          guarantorName: guarantorNameCtrl.text.trim(),
                          guarantorPhone: guarantorPhoneCtrl.text.trim(),
                          securityType: selectedSecurityType,
                          securityDetails: cleanSecurityDetails,
                          installmentComment: commentCtrl.text.trim(),
                          totalDue: parsedDue,
                          nextInstallmentDate:
                          parsedDue > 0 ? selectedNextDate : null,
                          createdAt: existingCustomer.createdAt,
                        );
                        customerController.updateCustomer(updatedCustomer);
                      } else {
                        final newCustomer = CustomerModel(
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          address: addressCtrl.text.trim(),
                          bikeDetails: bikeDetailsCtrl.text.trim(),
                          guarantorName: guarantorNameCtrl.text.trim(),
                          guarantorPhone: guarantorPhoneCtrl.text.trim(),
                          securityType: selectedSecurityType,
                          securityDetails: cleanSecurityDetails,
                          createdAt: DateTime.now(),
                        );
                        customerController.addCustomer(newCustomer);
                      }
                    }
                  },
                  child: customerController.isLoading.value
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    isEditing ? "আপডেট করুন" : "সেভ করুন",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}