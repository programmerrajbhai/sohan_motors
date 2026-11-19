import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../models/customer_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../dashboard/custom_sidebar.dart';

class DueCollectionScreen extends StatefulWidget {
  const DueCollectionScreen({Key? key}) : super(key: key);

  @override
  State<DueCollectionScreen> createState() => _DueCollectionScreenState();
}

class _DueCollectionScreenState extends State<DueCollectionScreen> {
  final CustomerController customerController = Get.put(CustomerController());
  final TextEditingController searchCtrl = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
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

  bool _matchesSearch(CustomerModel c) {
    if (searchQuery.trim().isEmpty) return true;
    final q = searchQuery.trim().toLowerCase();
    return c.name.toLowerCase().contains(q) ||
        c.phone.toLowerCase().contains(q) ||
        c.bikeDetails.toLowerCase().contains(q) ||
        c.installmentComment.toLowerCase().contains(q);
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
          "Due / Installment",
          style: TextStyle(color: AppColors.pureWhite),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "কিস্তি ও বকেয়া আদায়",
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
                              hintText: "Search name, phone, bike or comment...",
                              prefixIcon: Icon(Icons.search, color: AppColors.textGray),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
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

                    final allDueCustomers = allCustomers
                        .where((c) => c.totalDue > 0 && _matchesSearch(c))
                        .toList();

                    final expiredList = allDueCustomers
                        .where((c) => customerController.isDateExpired(c))
                        .toList();

                    final activeList = allDueCustomers
                        .where((c) => !customerController.isDateExpired(c))
                        .toList();

                    if (allDueCustomers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade300),
                            const SizedBox(height: 15),
                            const Text(
                              "আলহামদুলিল্লাহ!",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "মার্কেটে এই মুহূর্তে কোনো বকেয়া নেই।",
                              style: TextStyle(fontSize: 16, color: AppColors.textGray),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isMobile) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: TextField(
                                controller: searchCtrl,
                                onChanged: (val) => setState(() => searchQuery = val),
                                decoration: const InputDecoration(
                                  hintText: "Search name, phone, bike or comment...",
                                  prefixIcon: Icon(Icons.search, color: AppColors.textGray),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                                ),
                              ),
                            ),
                          ],
                          _buildExpiredSection(context, expiredList),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "All Due / Upcoming Installments",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.solidBlack,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${activeList.length} Person(s)",
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (activeList.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: const Text(
                                "চলমান বা আপকামিং তারিখের কোনো কাস্টমার নেই।",
                                style: TextStyle(color: AppColors.textGray),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 450,
                                mainAxisExtent: 315,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                              itemCount: activeList.length,
                              itemBuilder: (context, index) =>
                                  _buildDueCard(context, activeList[index], isExpired: false),
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

  Widget _buildExpiredSection(BuildContext context, List<CustomerModel> expiredList) {
    double sectionExpiredTotal = 0.0;
    for (var c in expiredList) {
      sectionExpiredTotal += c.totalDue;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.shade50.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runAlignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event_busy, color: Colors.red, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date Expired Customers (মেয়াদোত্তীর্ণ কিস্তি)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "যাদের নির্ধারিত কিস্তি/বকেয়ার তারিখ পার হয়ে গেছে",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _buildSummaryChip(
                    label: "Expired Person",
                    value: "${expiredList.length}",
                    bgColor: Colors.red,
                  ),
                  _buildSummaryChip(
                    label: "Expired Due",
                    value: "৳${sectionExpiredTotal.toInt()}",
                    bgColor: const Color(0xFF991B1B),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (expiredList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.green, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "কোনো কাস্টমারের কিস্তির তারিখ এক্সপায়ার্ড হয়নি।",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 450,
                mainAxisExtent: 325,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              itemCount: expiredList.length,
              itemBuilder: (context, index) =>
                  _buildDueCard(context, expiredList[index], isExpired: true),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({
    required String label,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDueCard(
      BuildContext context,
      CustomerModel customer, {
        required bool isExpired,
      }) {
    final int expiredDays = customerController.expiredDaysCount(customer);
    final bool hasComment = customer.installmentComment.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isExpired
                ? Colors.redAccent.withOpacity(0.12)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isExpired ? Colors.redAccent : Colors.black12,
          width: isExpired ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 12, color: AppColors.textGray),
                          const SizedBox(width: 5),
                          Text(
                            customer.phone,
                            style: const TextStyle(fontSize: 13, color: AppColors.textGray),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      expiredDays > 0 ? "$expiredDays দিন পার" : "Expired",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (customer.bikeDetails.isNotEmpty) ...[
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.two_wheeler, size: 14, color: AppColors.textGray),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      customer.bikeDetails,
                      style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Colors.black12, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "মোট বকেয়া:",
                  style: TextStyle(
                    fontSize: 14.5,
                    color: AppColors.textGray,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "৳${customer.totalDue.toInt()}",
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isExpired ? Colors.red.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: isExpired ? Colors.red : AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "কিস্তির তারিখ: ",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isExpired ? Colors.red : AppColors.textGray,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      customer.nextInstallmentDate != null
                          ? _formatDate(customer.nextInstallmentDate!)
                          : "কিস্তির তারিখ নেই",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isExpired ? Colors.red : AppColors.solidBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showCommentDialog(context, customer),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: hasComment ? Colors.amber.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasComment ? Colors.amber.shade300 : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.comment,
                      size: 15,
                      color: hasComment ? Colors.amber.shade900 : AppColors.textGray,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        hasComment
                            ? "Comment: ${customer.installmentComment}"
                            : "কিস্তির সংখ্যা / ডেট কমেন্ট লিখুন...",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: hasComment ? FontWeight.w600 : FontWeight.normal,
                          color: hasComment ? AppColors.solidBlack : AppColors.textGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.edit_note, size: 17, color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExpired ? Colors.redAccent : AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showCollectionDialog(context, customer),
                icon: const Icon(Icons.payments, color: Colors.white, size: 18),
                label: const Text(
                  "কিস্তি আদায় করুন",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentDialog(BuildContext context, CustomerModel customer) {
    final commentCtrl = TextEditingController(text: customer.installmentComment);
    final List<String> quickNotes = [
      "কিস্তির ডেট নেই",
      "১টি কিস্তি বাকি",
      "২টি কিস্তি বাকি",
      "৩টি কিস্তি বাকি",
      "ফোনে কথা হয়েছে, ডেট দিবে",
    ];

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                const Icon(Icons.comment, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "কিস্তি কমেন্ট (${customer.name})",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "কয়টা কিস্তি আছে/নেই বা তারিখের বিস্তারিত লিখুন:",
                    style: TextStyle(fontSize: 13, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: quickNotes.map((note) {
                      return ActionChip(
                        label: Text(note, style: const TextStyle(fontSize: 11.5)),
                        onPressed: () {
                          commentCtrl.text = note;
                          setDialogState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "যেমন: ২টা কিস্তি বাকি আছে, পরের ডেট নেই...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
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
                  onPressed: customerController.isLoading.value || customer.id == null
                      ? null
                      : () => customerController.updateInstallmentComment(
                    customer.id!,
                    commentCtrl.text,
                  ),
                  child: customerController.isLoading.value
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text("সেভ করুন", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCollectionDialog(BuildContext context, CustomerModel customer) {
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    final discountCtrl = TextEditingController(text: '0');
    final commentCtrl = TextEditingController(text: customer.installmentComment);
    DateTime? selectedNextDate;

    final List<String> quickNotes = [
      "কিস্তির ডেট নেই",
      "১টি কিস্তি বাকি",
      "২টি কিস্তি বাকি",
      "৩টি কিস্তি বাকি",
    ];

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          final double collectVal = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
          final double discountVal = double.tryParse(discountCtrl.text.trim()) ?? 0.0;
          final double totalDeducted = collectVal + discountVal;
          final double previewRemaining = (customer.totalDue - totalDeducted) < 0
              ? 0.0
              : (customer.totalDue - totalDeducted);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: AppColors.primaryBlue),
                SizedBox(width: 10),
                Text(
                  "কিস্তি জমা নিন",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "কাস্টমার: ${customer.name}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.solidBlack,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "বর্তমান বকেয়া: ৳${customer.totalDue.toInt()}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "জমা দেওয়ার পরিমাণ (৳)",
                          prefixIcon: const Icon(Icons.monetization_on, color: AppColors.accentBlue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                        validator: (val) {
                          final double? amount = double.tryParse(val?.trim() ?? '');
                          final double disc = double.tryParse(discountCtrl.text.trim()) ?? 0.0;
                          if (amount == null || amount < 0) return "সঠিক টাকার পরিমাণ দিন";
                          if (amount == 0 && disc <= 0) {
                            return "জমা অথবা ডিসকাউন্টের পরিমাণ দিন";
                          }
                          if ((amount + disc) > customer.totalDue + 0.01) {
                            return "জমা ও ডিসকাউন্ট মিলে বকেয়ার চেয়ে বেশি হতে পারবে না";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: discountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "ডিসকাউন্ট / ছাড় (Discount ৳)",
                          prefixIcon: const Icon(Icons.discount, color: Colors.green),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return null;
                          final double? disc = double.tryParse(val.trim());
                          if (disc == null || disc < 0) return "সঠিক ডিসকাউন্ট দিন";
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "মোট সমন্বয় (জমা + ডিসকাউন্ট):",
                                  style: TextStyle(fontSize: 13),
                                ),
                                Text(
                                  "৳${totalDeducted.toInt()}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "অবশিষ্ট বকেয়া:",
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "৳${previewRemaining.toInt()}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "কিস্তির সংখ্যা / তারিখের কমেন্ট (কয়টা কিস্তি আছে বা নেই)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textGray,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: quickNotes.map((note) {
                          return ActionChip(
                            label: Text(note, style: const TextStyle(fontSize: 11)),
                            onPressed: () {
                              commentCtrl.text = note;
                              setDialogState(() {});
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: commentCtrl,
                        decoration: InputDecoration(
                          labelText: "Comment / Note",
                          hintText: "যেমন: ২টা কিস্তি বাকি, ডেট নেই...",
                          prefixIcon: const Icon(Icons.comment, color: AppColors.primaryBlue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (previewRemaining > 0) ...[
                        const Text(
                          "পরবর্তী কিস্তির তারিখ (ঐচ্ছিক)",
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGray),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(const Duration(days: 30)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setDialogState(() => selectedNextDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedNextDate != null
                                      ? _formatDate(selectedNextDate!)
                                      : "তারিখ নির্বাচন করুন (অথবা ডেট না থাকলে ফাঁকা রাখুন)",
                                  style: TextStyle(
                                    color: selectedNextDate != null
                                        ? AppColors.solidBlack
                                        : Colors.black54,
                                  ),
                                ),
                                const Icon(Icons.calendar_month, color: AppColors.primaryBlue),
                              ],
                            ),
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
                      final double collectedAmount =
                          double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                      final double discountAmount =
                          double.tryParse(discountCtrl.text.trim()) ?? 0.0;
                      customerController.collectDue(
                        customer,
                        collectedAmount,
                        selectedNextDate,
                        discountAmount: discountAmount,
                        comment: commentCtrl.text,
                      );
                    }
                  },
                  child: customerController.isLoading.value
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text("কনফার্ম করুন", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}