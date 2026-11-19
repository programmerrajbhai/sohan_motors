import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../dashboard/dashboard_screen.dart';

class InstallmentReceiptScreen extends StatelessWidget {
  final String customerName;
  final String phone;
  final double collectedAmount;
  final double remainingDue;
  final DateTime? nextInstallmentDate;

  const InstallmentReceiptScreen({
    Key? key,
    required this.customerName,
    required this.phone,
    required this.collectedAmount,
    required this.remainingDue,
    this.nextInstallmentDate,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Money Receipt", style: TextStyle(color: AppColors.pureWhite)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.offAll(() => const DashboardScreen()),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.snackbar("Print", "প্রিন্টিং সিস্টেম কাজ করছে...", backgroundColor: AppColors.solidBlack, colorText: Colors.white),
        backgroundColor: AppColors.solidBlack,
        icon: const Icon(Icons.print, color: AppColors.pureWhite),
        label: const Text("PRINT RECEIPT", style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: isMobile ? double.infinity : 600,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 10),
                const Text("Payment Received", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                Text(_formatDate(DateTime.now()), style: const TextStyle(color: AppColors.textGray)),

                const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.black26, thickness: 1, )),

                _buildRow("Customer Name:", customerName, isBold: true),
                const SizedBox(height: 10),
                _buildRow("Mobile Number:", phone),

                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withOpacity(0.2))),
                  child: Column(
                    children: [
                      _buildRow("Amount Paid:", "৳${collectedAmount.toInt()}", valueColor: Colors.green, isValueBold: true, valueSize: 22),
                      const Divider(height: 30),
                      _buildRow("Remaining Due:", "৳${remainingDue.toInt()}", valueColor: remainingDue > 0 ? Colors.red : Colors.green, isValueBold: true),
                      if (remainingDue > 0 && nextInstallmentDate != null) ...[
                        const SizedBox(height: 10),
                        _buildRow("Next Installment:", _formatDate(nextInstallmentDate!), isValueBold: true),
                      ]
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Container(width: 120, height: 1, color: Colors.black),
                        const SizedBox(height: 5),
                        const Text("Customer Sign", style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(width: 120, height: 1, color: Colors.black),
                        const SizedBox(height: 5),
                        const Text("Authorized Sign", style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color valueColor = AppColors.solidBlack, bool isValueBold = false, double valueSize = 16}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: AppColors.textGray)),
        Text(value, style: TextStyle(fontSize: valueSize, fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal, color: valueColor)),
      ],
    );
  }
}