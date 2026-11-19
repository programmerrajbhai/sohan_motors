import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/reports_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../dashboard/custom_sidebar.dart';

class ReportsScreen extends StatelessWidget {
  ReportsScreen({Key? key}) : super(key: key);

  final ReportsController reportsController = Get.put(ReportsController());

  String _formatDate(dynamic dateInput) {
    if (dateInput == null) return "N/A";
    final DateTime date =
    dateInput is Timestamp ? dateInput.toDate() : (dateInput as DateTime);
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveLayout.isMobile(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: isMobile
            ? AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: const Text(
            "Reports & Analytics",
            style: TextStyle(color: AppColors.pureWhite),
          ),
          iconTheme: const IconThemeData(color: AppColors.pureWhite),
          elevation: 0,
        )
            : null,
        drawer: isMobile ? const CustomSidebar(isMobile: true) : null,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddExpenseDialog(context),
          backgroundColor: AppColors.primaryBlue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "খরচ যুক্ত করুন",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) const CustomSidebar(isMobile: false),
            Expanded(
              child: Column(
                children: [
                  Container(
                    color: AppColors.pureWhite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMobile)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(25, 22, 25, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Business Reports, Income-Expense & Profit",
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.solidBlack,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => _showAddExpenseDialog(context),
                                  icon: const Icon(Icons.add_card, color: Colors.white, size: 18),
                                  label: const Text(
                                    "Add Daily / Other Cost",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const TabBar(
                          labelColor: AppColors.primaryBlue,
                          unselectedLabelColor: AppColors.textGray,
                          indicatorColor: AppColors.primaryBlue,
                          indicatorWeight: 3,
                          tabs: [
                            Tab(icon: Icon(Icons.account_balance_wallet), text: "আয়-ব্যয় ও লাভ"),
                            Tab(icon: Icon(Icons.receipt_long), text: "দৈনিক আদায়"),
                            Tab(icon: Icon(Icons.warning_amber_rounded), text: "কিস্তি মিস"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (reportsController.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryBlue),
                        );
                      }

                      return TabBarView(
                        children: [
                          _buildSummaryTab(context, isMobile),
                          _buildCollectionTab(),
                          _buildOverdueTab(),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab(BuildContext context, bool isMobile) {
    final double netAfterTotal = reportsController.netProfitAfterTotalCost.value;
    final double netAfterDaily = reportsController.netProfitAfterDailyCost.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 18,
            runSpacing: 18,
            children: [
              _buildReportCard(
                "মোট আয় (Total Income)",
                "৳${reportsController.totalIncome.value.toInt()}",
                "আজকের আদায়: ৳${reportsController.todayIncome.value.toInt()}",
                Icons.trending_up,
                Colors.teal,
              ),
              _buildReportCard(
                "মোট খরচ (Total Expense)",
                "৳${reportsController.totalExpense.value.toInt()}",
                "দৈনিক খরচ (Today): ৳${reportsController.todayExpense.value.toInt()}",
                Icons.money_off,
                Colors.orange,
              ),
              _buildReportCard(
                "বর্তমান স্টকের মূল্য",
                "৳${reportsController.currentStockValue.value.toInt()}",
                "মোট ব্যয় + স্টক: ৳${reportsController.totalCostWithStock.value.toInt()}",
                Icons.storefront,
                Colors.blue,
              ),
              _buildReportCard(
                netAfterTotal >= 0 ? "নিট লাভ (মোট খরচ বাদে)" : "নিট ক্ষতি (মোট খরচ বাদে)",
                "${netAfterTotal >= 0 ? '+' : '-'}৳${netAfterTotal.abs().toInt()}",
                "গ্রস লাভ: ৳${reportsController.grossProfit.value.toInt()}",
                netAfterTotal >= 0 ? Icons.paid : Icons.trending_down,
                netAfterTotal >= 0 ? Colors.green : Colors.red,
              ),
              _buildReportCard(
                netAfterDaily >= 0
                    ? "নিট লাভ (দৈনিক খরচ বাদে)"
                    : "নিট ক্ষতি (দৈনিক খরচ বাদে)",
                "${netAfterDaily >= 0 ? '+' : '-'}৳${netAfterDaily.abs().toInt()}",
                "আজকের দৈনিক খরচ: ৳${reportsController.todayExpense.value.toInt()}",
                netAfterDaily >= 0 ? Icons.savings : Icons.report_problem,
                netAfterDaily >= 0 ? Colors.indigo : Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "দৈনিক ও অন্যান্য খরচের তালিকা (Expenses)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.solidBlack,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddExpenseDialog(context),
                icon: const Icon(Icons.add, color: AppColors.primaryBlue),
                label: const Text(
                  "খরচ যোগ করুন",
                  style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (reportsController.expenses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: const Text(
                "কোনো খরচের রেকর্ড যুক্ত করা হয়নি।",
                style: TextStyle(color: AppColors.textGray),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reportsController.expenses.length,
              itemBuilder: (context, index) {
                final exp = reportsController.expenses[index];
                return Card(
                  elevation: 1.5,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withOpacity(0.12),
                      child: const Icon(Icons.receipt, color: Colors.orange),
                    ),
                    title: Text(
                      exp.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${exp.category}  |  ${_formatDate(exp.date)}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "- ৳${exp.amount.toInt()}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => reportsController.deleteExpense(exp.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCollectionTab() {
    if (reportsController.transactions.isEmpty) {
      return const Center(child: Text("কোনো লেনদেন পাওয়া যায়নি।"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reportsController.transactions.length,
      itemBuilder: (context, index) {
        var trans = reportsController.transactions[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: const Icon(Icons.payments, color: Colors.green),
            ),
            title: Text(
              "আদায়: ${trans['customerName'] ?? 'N/A'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${trans['type'] ?? ''}  |  ${_formatDate(trans['date'])}"),
            trailing: Text(
              "+ ৳${((trans['amount'] is num ? (trans['amount'] as num).toDouble() : double.tryParse(trans['amount']?.toString() ?? '0') ?? 0.0)).toInt()}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverdueTab() {
    if (reportsController.overdueCustomers.isEmpty) {
      return const Center(
        child: Text(
          "আলহামদুলিল্লাহ! কেউ কিস্তি মিস করেনি।",
          style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reportsController.overdueCustomers.length,
      itemBuilder: (context, index) {
        var customer = reportsController.overdueCustomers[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.redAccent, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.warning, color: Colors.white),
            ),
            title: Text(
              customer.name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.solidBlack),
            ),
            subtitle: Text(
              "কথা ছিল: ${_formatDate(customer.nextInstallmentDate)} তারিখে\nমোবাইল: ${customer.phone}",
            ),
            trailing: Text(
              "বকেয়া: ৳${customer.totalDue.toInt()}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildReportCard(
      String title,
      String amount,
      String subtitle,
      IconData icon,
      Color color,
      ) {
    return Container(
      width: 310,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 15, color: AppColors.textGray, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedCategory = 'Daily Cost';
    DateTime pickedDate = DateTime.now();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Row(
              children: [
                Icon(Icons.add_card, color: AppColors.primaryBlue),
                SizedBox(width: 10),
                Text(
                  "খরচ যুক্ত করুন",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                ),
              ],
            ),
            content: SizedBox(
              width: 390,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: "খরচের ধরন",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Daily Cost", child: Text("দৈনিক খরচ (Daily Cost)")),
                        DropdownMenuItem(value: "Other Expense", child: Text("অন্যান্য খরচ (Other Expense)")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: "খরচের বিবরণ *",
                        hintText: "যেমন: নাস্তা, বিদ্যুৎ বিল, দোকান ভাড়া...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "খরচের বিবরণ লিখুন" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "টাকার পরিমাণ (৳) *",
                        prefixText: "৳ ",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (v) {
                        final amt = double.tryParse(v?.trim() ?? '');
                        if (amt == null || amt <= 0) return "সঠিক টাকার পরিমাণ দিন";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: pickedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (d != null) setDialogState(() => pickedDate = d);
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
                            Text("তারিখ: ${_formatDate(pickedDate)}"),
                            const Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                  onPressed: reportsController.isAddingExpense.value
                      ? null
                      : () {
                    if (formKey.currentState!.validate()) {
                      reportsController.addExpense(
                        title: titleCtrl.text.trim(),
                        amount: double.parse(amountCtrl.text.trim()),
                        category: selectedCategory,
                        date: pickedDate,
                      );
                    }
                  },
                  child: reportsController.isAddingExpense.value
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
}