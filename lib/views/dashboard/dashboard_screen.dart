import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../pos/pos_sale_screen.dart';
import 'custom_sidebar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveLayout.isMobile(context);
    final DashboardController dashboardController = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: isMobile
          ? AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text("Dashboard", style: TextStyle(color: AppColors.pureWhite)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                    decoration: const BoxDecoration(
                      color: AppColors.pureWhite,
                      border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "Overview / Dashboard",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.solidBlack),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome back, Sohan Motors!",
                          style: TextStyle(fontSize: 20, color: AppColors.textGray, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Here is your showroom's live stock, today's stock & due summary.",
                          style: TextStyle(fontSize: 15, color: AppColors.textGray),
                        ),
                        const SizedBox(height: 30),

                        Obx(() {
                          if (dashboardController.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(color: AppColors.primaryBlue),
                              ),
                            );
                          }

                          final double totalStockAmt = dashboardController.totalStockAmount.value;
                          final int todayCount = dashboardController.todayStockCount.value;
                          final double todayAmt = dashboardController.todayStockAmount.value;
                          final double totalDue = dashboardController.totalDueAmount.value;
                          final double stockPlusDue = totalStockAmt + totalDue;

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = isMobile ? 1 : (constraints.maxWidth > 1050 ? 3 : 2);
                              return GridView.count(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                shrinkWrap: true,
                                childAspectRatio: isMobile ? 2.3 : 1.75,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildStatCard(
                                    title: "Total Stock Amount",
                                    value: "৳${totalStockAmt.toInt()}",
                                    icon: Icons.inventory_2,
                                    color: Colors.blue,
                                    subtitle: "${dashboardController.totalBikes.value} bikes available in stock",
                                  ),
                                  _buildStatCard(
                                    title: "Today Stock",
                                    value: "৳${todayAmt.toInt()}",
                                    icon: Icons.add_shopping_cart,
                                    color: Colors.teal,
                                    subtitle: "$todayCount bike(s) added today",
                                  ),
                                  _buildStatCard(
                                    title: "Due Amount",
                                    value: "৳${totalDue.toInt()}",
                                    icon: Icons.account_balance_wallet,
                                    color: Colors.redAccent,
                                    subtitle: "${dashboardController.totalCustomers.value} total customers",
                                  ),
                                  _buildStatCard(
                                    title: "Stock + Due Total",
                                    value: "৳${stockPlusDue.toInt()}",
                                    icon: Icons.account_balance,
                                    color: Colors.indigo,
                                    subtitle: "Stock (৳${totalStockAmt.toInt()}) + Due (৳${totalDue.toInt()})",
                                  ),
                                  _buildStatCard(
                                    title: "Total Sales",
                                    value: "৳${dashboardController.totalSalesAmount.value.toInt()}",
                                    icon: Icons.monetization_on,
                                    color: Colors.green,
                                    subtitle: "Overall showroom sales",
                                  ),
                                ],
                              );
                            },
                          );
                        }),

                        const SizedBox(height: 40),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.primaryBlue, Color(0xFF1E3C72)]),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Ready for a New Sale?",
                                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Navigate to the POS panel to process new bike sales and print instant invoices.",
                                      style: TextStyle(color: Colors.white70, fontSize: 15),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      onPressed: () => Get.to(() => const PosSaleScreen()),
                                      icon: const Icon(Icons.point_of_sale, color: AppColors.primaryBlue),
                                      label: const Text(
                                        "Go to POS",
                                        style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isMobile) const Icon(Icons.motorcycle, size: 100, color: Colors.white24),
                            ],
                          ),
                        ),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 35, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, color: AppColors.textGray, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.solidBlack)),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}