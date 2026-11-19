import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/export_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../dashboard/custom_sidebar.dart';

class ExportScreen extends StatelessWidget {
  ExportScreen({Key? key}) : super(key: key);

  final ExportController exportController = Get.put(ExportController());

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: isMobile
          ? AppBar(backgroundColor: AppColors.primaryBlue, title: const Text("Data Export", style: TextStyle(color: AppColors.pureWhite)), iconTheme: const IconThemeData(color: AppColors.pureWhite), elevation: 0)
          : null,
      drawer: isMobile ? const CustomSidebar(isMobile: true) : null,

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) const CustomSidebar(isMobile: false),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                    decoration: const BoxDecoration(color: AppColors.pureWhite, border: Border(bottom: BorderSide(color: Colors.black12, width: 1))),
                    child: const Row(children: [Text("Data Backup & Export", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.solidBlack))]),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Export Your Data Safely", style: TextStyle(fontSize: 20, color: AppColors.textGray, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        const Text("যেকোনো ডেটা এক ক্লিকেই Excel/CSV ফরম্যাটে ডাউনলোড করে সুরক্ষিত রাখুন।", style: TextStyle(fontSize: 15, color: AppColors.textGray)),
                        const SizedBox(height: 30),

                        Obx(() {
                          if (exportController.isLoading.value) {
                            return const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: AppColors.primaryBlue)));
                          }
                          return Wrap(
                            spacing: 20, runSpacing: 20,
                            children: [
                              _buildExportCard(
                                title: "Bike Stock Data",
                                description: "স্টকে থাকা এবং বিক্রি হওয়া সব বাইকের বিস্তারিত তথ্য।",
                                icon: Icons.motorcycle,
                                color: Colors.blue,
                                onExport: exportController.exportBikes,
                              ),
                              _buildExportCard(
                                title: "Customer Database",
                                description: "সব কাস্টমারের নাম, ঠিকানা, নম্বর এবং বকেয়ার তথ্য।",
                                icon: Icons.people_alt,
                                color: Colors.orange,
                                onExport: exportController.exportCustomers,
                              ),
                              _buildExportCard(
                                title: "Sales History",
                                description: "শোরুমের সমস্ত বিক্রি, ডিসকাউন্ট ও পেমেন্ট রেকর্ড।",
                                icon: Icons.point_of_sale,
                                color: Colors.green,
                                onExport: exportController.exportSales,
                              ),
                              _buildExportCard(
                                title: "Daily Transactions",
                                description: "দৈনিক আদায়, ডাউনপেমেন্ট এবং কিস্তি আদায়ের রিপোর্ট।",
                                icon: Icons.receipt_long,
                                color: Colors.purple,
                                onExport: exportController.exportTransactions,
                              ),
                            ],
                          );
                        }),

                        const SizedBox(height: 50),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withOpacity(0.2))),
                          child: const Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue),
                              SizedBox(width: 15),
                              Expanded(child: Text("ডাউনলোড করা ফাইলগুলো আপনি Microsoft Excel, Google Sheets বা যেকোনো স্প্রেডশিট ভিউয়ারে ওপেন করতে পারবেন।", style: TextStyle(color: Colors.blue))),
                            ],
                          ),
                        )
                      ],
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

  Widget _buildExportCard({required String title, required String description, required IconData icon, required Color color, required VoidCallback onExport}) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 30, color: color)),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.solidBlack)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 13, color: AppColors.textGray)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 45,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: onExport,
              icon: const Icon(Icons.download, color: Colors.white, size: 18),
              label: const Text("EXPORT CSV", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}