import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../dashboard/dashboard_screen.dart';
import '../stock/stock_list_screen.dart';
import '../pos/pos_sale_screen.dart';
import '../customer/customer_list_screen.dart';
import '../due/due_collection_screen.dart';
import '../reports/reports_screen.dart';
import '../export/export_screen.dart';

class CustomSidebar extends StatelessWidget {
  final bool isMobile;
  const CustomSidebar({Key? key, required this.isMobile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentRoute = Get.currentRoute;

    Widget sidebarContent = Column(
      children: [
        // প্রিমিয়াম গ্রেডিয়েন্ট হেডার (লোগো সহ)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 45, bottom: 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, Color(0xFF162B54)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(35)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // লোগো বসানোর সুন্দর কন্টেইনার
              // লোগো বসানোর সুন্দর কন্টেইনার
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)
                    ]
                ),
                child: ClipOval(
                  // লোকাল অ্যাসেট থেকে লোগো লোড করা (CORS বা অন্য কোনো সমস্যা করবে না)
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.two_wheeler, size: 45, color: AppColors.primaryBlue);
                    },
                  ),
                ),
              ),


              const SizedBox(height: 15),
              const Text(
                  "Sohan Motors",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.pureWhite, letterSpacing: 1.2)
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                ),
                child: const Text("Showroom Panel", style: TextStyle(fontSize: 11, color: AppColors.pureWhite, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // স্টাইলিশ মেন্যু আইটেমস
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildMenuItem(context, title: "Dashboard", icon: Icons.dashboard_rounded, isActive: currentRoute.contains('DashboardScreen'), onTap: () => _navigate(context, const DashboardScreen())),
                _buildMenuItem(context, title: "Bike Stock", icon: Icons.motorcycle_rounded, isActive: currentRoute.contains('StockListScreen'), onTap: () => _navigate(context, StockListScreen())),
                _buildMenuItem(context, title: "POS / Sell", icon: Icons.point_of_sale_rounded, isActive: currentRoute.contains('PosSaleScreen'), onTap: () => _navigate(context, const PosSaleScreen())),
                _buildMenuItem(context, title: "Customers", icon: Icons.people_alt_rounded, isActive: currentRoute.contains('CustomerListScreen'), onTap: () => _navigate(context, CustomerListScreen())),
                _buildMenuItem(context, title: "Due / Installment", icon: Icons.account_balance_wallet_rounded, isActive: currentRoute.contains('DueCollectionScreen'), onTap: () => _navigate(context, DueCollectionScreen())),
                _buildMenuItem(context, title: "Reports & Analytics", icon: Icons.bar_chart_rounded, isActive: currentRoute.contains('ReportsScreen'), onTap: () => _navigate(context, ReportsScreen())),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: Divider(color: Colors.black12, height: 1),
                ),

                _buildMenuItem(context, title: "Data Backup & Export", icon: Icons.import_export_rounded, isActive: currentRoute.contains('ExportScreen'), onTap: () => _navigate(context, ExportScreen())),
              ],
            ),
          ),
        ),

        // মডার্ন লগআউট বাটন
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: InkWell(
            onTap: () {
              Get.defaultDialog(
                  title: "Logout",
                  middleText: "আপনি কি প্যানেল থেকে বের হতে চান?",
                  textConfirm: "হ্যাঁ",
                  textCancel: "না",
                  confirmTextColor: Colors.white,
                  cancelTextColor: Colors.black54,
                  buttonColor: Colors.redAccent,
                  titleStyle: const TextStyle(fontWeight: FontWeight.bold),
                  onConfirm: () {}
              );
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 22),
                  const SizedBox(width: 10),
                  Text("Logout Account", style: TextStyle(color: Colors.red.shade600, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return isMobile
        ? Drawer(
        backgroundColor: AppColors.backgroundWhite,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(20))),
        child: sidebarContent
    )
        : Container(
      width: 270,
      decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(5, 0))]
      ),
      child: sidebarContent,
    );
  }

  Widget _buildMenuItem(BuildContext context, {required String title, required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: AppColors.primaryBlue.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.primaryBlue.withOpacity(0.2) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? AppColors.primaryBlue : AppColors.textGray.withOpacity(0.8), size: 22),
              const SizedBox(width: 16),
              Text(
                  title,
                  style: TextStyle(
                      color: isActive ? AppColors.primaryBlue : AppColors.solidBlack.withOpacity(0.8),
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      letterSpacing: 0.3
                  )
              ),
              const Spacer(),
              if (isActive)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    if (isMobile) Get.back();
    Get.offAll(() => screen, transition: Transition.fadeIn, duration: const Duration(milliseconds: 200));
  }
}