import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/sale_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../dashboard/dashboard_screen.dart';

class InvoiceScreen extends StatelessWidget {
  final SaleModel sale;

  const InvoiceScreen({Key? key, required this.sale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Invoice Preview", style: TextStyle(color: AppColors.pureWhite)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAll(() => const DashboardScreen()), // ব্যাক করলে সোজা ড্যাশবোর্ডে যাবে
        ),
      ),
      // প্রিন্ট বাটন
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // পরবর্তীতে এখানে PDF Generate এবং Print এর লজিক বসবে
          Get.snackbar("Print", "প্রিন্টিং সিস্টেম পরবর্তীতে যুক্ত করা হবে।", backgroundColor: AppColors.solidBlack, colorText: AppColors.pureWhite);
        },
        backgroundColor: AppColors.solidBlack,
        icon: const Icon(Icons.print, color: AppColors.pureWhite),
        label: const Text("PRINT INVOICE", style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: isMobile ? double.infinity : 700,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // হেডার (শোরুমের তথ্য)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.two_wheeler, size: 30, color: AppColors.primaryBlue),
                            SizedBox(width: 10),
                            Text("Sohan Motors", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text("Paschim Chhatnai, Dimla, Nilphamari", style: TextStyle(color: AppColors.textGray)),
                        Text("Phone: +880 1700-000000", style: TextStyle(color: AppColors.textGray)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("INVOICE", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.solidBlack, letterSpacing: 2)),
                        const SizedBox(height: 5),
                        Text("Date: ${DateFormat('dd MMM, yyyy').format(sale.saleDate)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Time: ${DateFormat('hh:mm a').format(sale.saleDate)}", style: const TextStyle(color: AppColors.textGray)),
                      ],
                    ),
                  ],
                ),

                const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.black, thickness: 1)),

                // কাস্টমার তথ্য
                const Text("Billed To:", style: TextStyle(fontSize: 14, color: AppColors.textGray)),
                Text(sale.customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.solidBlack)),
                // যদি কাস্টমারের ফোন বা অ্যাড্রেস SaleModel-এ রাখতেন তবে এখানে দেখানো যেত

                const SizedBox(height: 30),

                // বাইক এবং দামের টেবিল
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(5)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(5))),
                        child: const Row(
                          children: [
                            Expanded(flex: 3, child: Text("Description (Bike Details)", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 1, child: Text("Amount", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: Text(sale.bikeDetails, style: const TextStyle(fontSize: 16))),
                            Expanded(flex: 1, child: Text("৳ ${sale.salePrice.toInt()}", textAlign: TextAlign.right, style: const TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // পেমেন্ট সামারি
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Column(
                        children: [
                          _buildSummaryRow("Subtotal:", "৳ ${sale.salePrice.toInt()}"),
                          _buildSummaryRow("Discount:", "- ৳ ${sale.discount.toInt()}", color: Colors.green),
                          const Divider(),
                          _buildSummaryRow("Grand Total:", "৳ ${(sale.salePrice - sale.discount).toInt()}", isBold: true),
                          const SizedBox(height: 10),
                          _buildSummaryRow("Paid Amount:", "৳ ${sale.paidAmount.toInt()}"),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(color: sale.dueAmount > 0 ? Colors.redAccent.withOpacity(0.1) : Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                            child: _buildSummaryRow("Due Amount:", "৳ ${sale.dueAmount.toInt()}", color: sale.dueAmount > 0 ? Colors.red : Colors.green, isBold: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // স্বাক্ষর
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Container(width: 150, height: 1, color: Colors.black),
                        const SizedBox(height: 5),
                        const Text("Customer Signature", style: TextStyle(color: AppColors.textGray)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(width: 150, height: 1, color: Colors.black),
                        const SizedBox(height: 5),
                        const Text("Authorized Signature", style: TextStyle(color: AppColors.textGray)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Center(child: Text("Thank you for your business!", style: TextStyle(color: AppColors.textGray, fontStyle: FontStyle.italic))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {Color color = AppColors.solidBlack, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: AppColors.textGray)),
          Text(amount, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}