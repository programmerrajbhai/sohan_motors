import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/stock_controller.dart';
import '../../models/bike_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../dashboard/custom_sidebar.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({Key? key}) : super(key: key);

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  final StockController stockController = Get.put(StockController());
  final TextEditingController searchCtrl = TextEditingController();
  String searchQuery = '';
  String statusFilter = 'All';

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  bool _matchesFilter(BikeModel bike) {
    if (statusFilter != 'All' && bike.status != statusFilter) {
      return false;
    }
    if (searchQuery.trim().isEmpty) return true;
    final q = searchQuery.trim().toLowerCase();
    return bike.brand.toLowerCase().contains(q) ||
        bike.model.toLowerCase().contains(q) ||
        bike.color.toLowerCase().contains(q) ||
        bike.registration.toLowerCase().contains(q) ||
        bike.chassisNo.toLowerCase().contains(q) ||
        bike.engineNo.toLowerCase().contains(q);
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
          "Bike Stock",
          style: TextStyle(color: AppColors.pureWhite),
        ),
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
        elevation: 0,
      )
          : null,
      drawer: isMobile ? const CustomSidebar(isMobile: true) : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBikeFormDialog(context),
        backgroundColor: AppColors.solidBlack,
        icon: const Icon(Icons.add, color: AppColors.pureWhite),
        label: const Text(
          "নতুন বাইক যুক্ত করুন",
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
                      border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Bike Stock Management",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.solidBlack,
                          ),
                        ),
                        Row(
                          children: [
                            _buildFilterChip("All"),
                            const SizedBox(width: 8),
                            _buildFilterChip("Available"),
                            const SizedBox(width: 8),
                            _buildFilterChip("Sold"),
                            const SizedBox(width: 16),
                            Container(
                              width: 280,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: TextField(
                                controller: searchCtrl,
                                onChanged: (val) => setState(() => searchQuery = val),
                                decoration: const InputDecoration(
                                  hintText: "Search brand, model, reg, chassis...",
                                  prefixIcon: Icon(Icons.search, color: AppColors.textGray),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Obx(() {
                    final filteredBikes =
                    stockController.bikeList.where(_matchesFilter).toList();

                    if (filteredBikes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.two_wheeler, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 15),
                            const Text(
                              "কোনো বাইক পাওয়া যায়নি।",
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (isMobile) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: TextField(
                                controller: searchCtrl,
                                onChanged: (val) => setState(() => searchQuery = val),
                                decoration: const InputDecoration(
                                  hintText: "Search brand, model, reg, chassis...",
                                  prefixIcon: Icon(Icons.search, color: AppColors.textGray),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip("All"),
                                  const SizedBox(width: 8),
                                  _buildFilterChip("Available"),
                                  const SizedBox(width: 8),
                                  _buildFilterChip("Sold"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 430,
                              mainAxisExtent: 315,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                            itemCount: filteredBikes.length,
                            itemBuilder: (context, index) =>
                                _buildBikeCard(context, filteredBikes[index]),
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

  Widget _buildFilterChip(String label) {
    final bool isSelected = statusFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.solidBlack,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) => setState(() => statusFilter = label),
    );
  }

  Widget _buildBikeCard(BuildContext context, BikeModel bike) {
    final bool isAvailable = bike.status == 'Available';
    final double profit = bike.estimatedProfit;
    final bool isProfitPositive = profit >= 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // হেডার: ছবি + ব্র্যান্ড/মডেল + স্ট্যাটাস + এডিট/ডিলিট
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: bike.imageUrl.isNotEmpty
                        ? Image.network(
                      bike.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.two_wheeler,
                        size: 32,
                        color: AppColors.primaryBlue,
                      ),
                    )
                        : const Icon(
                      Icons.two_wheeler,
                      size: 32,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${bike.brand} ${bike.model}".trim(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.solidBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // রঙের ঠিক পাশেই রেজিস্ট্রেশন
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildTagBadge(
                            icon: Icons.palette,
                            text: bike.color.isEmpty ? "N/A" : bike.color,
                            bgColor: Colors.blueGrey.shade50,
                            textColor: AppColors.solidBlack,
                          ),
                          _buildTagBadge(
                            icon: Icons.app_registration,
                            text: "Reg: ${bike.registration}",
                            bgColor: Colors.indigo.shade50,
                            textColor: Colors.indigo.shade700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.withOpacity(0.12)
                        : Colors.orange.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bike.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.green.shade700 : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // চেসিস ও ইঞ্জিন নম্বর
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Chassis: ${bike.chassisNo}",
                    style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Engine: ${bike.engineNo}",
                    style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Colors.black12, height: 1),
            ),

            // Buy Price, Sell Price এবং Profit বক্স
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriceCol("Buy Price", "৳${bike.purchasePrice.toInt()}", AppColors.solidBlack),
                  _buildPriceCol("Sell Price", "৳${bike.sellingPrice.toInt()}", AppColors.primaryBlue),
                  _buildPriceCol(
                    isProfitPositive ? "Profit" : "Loss",
                    "${isProfitPositive ? '+' : '-'}৳${profit.abs().toInt()}",
                    isProfitPositive ? Colors.green.shade700 : Colors.red,
                  ),
                ],
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showBikeFormDialog(context, existingBike: bike),
                  icon: const Icon(Icons.edit, size: 17, color: AppColors.primaryBlue),
                  label: const Text(
                    "Edit Price / Reg",
                    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                IconButton(
                  tooltip: "Delete Bike",
                  onPressed: () {
                    if (bike.id != null) {
                      stockController.deleteBike(bike.id!);
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagBadge({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCol(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGray)),
        const SizedBox(height: 2),
        Text(
          amount,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  void _showBikeFormDialog(BuildContext context, {BikeModel? existingBike}) {
    final bool isEditing = existingBike != null;
    final formKey = GlobalKey<FormState>();

    final brandCtrl = TextEditingController(text: existingBike?.brand ?? '');
    final modelCtrl = TextEditingController(text: existingBike?.model ?? '');
    final colorCtrl = TextEditingController(text: existingBike?.color ?? '');
    final regCtrl = TextEditingController(text: existingBike?.registration ?? 'Unregistered');
    final chassisCtrl = TextEditingController(text: existingBike?.chassisNo ?? '');
    final engineCtrl = TextEditingController(text: existingBike?.engineNo ?? '');
    final buyPriceCtrl = TextEditingController(
      text: existingBike != null && existingBike.purchasePrice > 0
          ? existingBike.purchasePrice.toInt().toString()
          : '',
    );
    final sellPriceCtrl = TextEditingController(
      text: existingBike != null && existingBike.sellingPrice > 0
          ? existingBike.sellingPrice.toInt().toString()
          : '',
    );
    String imageUrl = existingBike?.imageUrl ?? '';
    String selectedStatus = existingBike?.status ?? 'Available';

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          final double buyVal = double.tryParse(buyPriceCtrl.text.trim()) ?? 0.0;
          final double sellVal = double.tryParse(sellPriceCtrl.text.trim()) ?? 0.0;
          final double liveProfit = sellVal - buyVal;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                const Icon(Icons.two_wheeler, color: AppColors.primaryBlue),
                const SizedBox(width: 10),
                Text(
                  isEditing ? "বাইকের তথ্য এডিট করুন" : "নতুন বাইক স্টকে যুক্ত করুন",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
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
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: brandCtrl,
                              decoration: InputDecoration(
                                labelText: "ব্র্যান্ড *",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? "ব্র্যান্ড দিন" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: modelCtrl,
                              decoration: InputDecoration(
                                labelText: "মডেল *",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? "মডেল দিন" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // রঙের ঠিক পাশেই রেজিস্ট্রেশন ইনপুট
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: colorCtrl,
                              decoration: InputDecoration(
                                labelText: "রঙ (Color) *",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? "রঙ দিন" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: regCtrl,
                              decoration: InputDecoration(
                                labelText: "Registration",
                                hintText: "Unregistered / Reg No",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: chassisCtrl,
                              decoration: InputDecoration(
                                labelText: "চেসিস নম্বর *",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? "চেসিস নম্বর দিন" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: engineCtrl,
                              decoration: InputDecoration(
                                labelText: "ইঞ্জিন নম্বর *",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? "ইঞ্জিন নম্বর দিন" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Buy Price এবং Sell Price
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: buyPriceCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setDialogState(() {}),
                              decoration: InputDecoration(
                                labelText: "কেনার দাম (Buy Price) *",
                                prefixText: "৳ ",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) {
                                final d = double.tryParse(v?.trim() ?? '');
                                if (d == null || d < 0) return "সঠিক কেনা দাম দিন";
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: sellPriceCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setDialogState(() {}),
                              decoration: InputDecoration(
                                labelText: "বিক্রির দাম (Sell Price) *",
                                prefixText: "৳ ",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) {
                                final d = double.tryParse(v?.trim() ?? '');
                                if (d == null || d < 0) return "সঠিক বিক্রির দাম দিন";
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // লাইভ Profit Preview বক্স
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: liveProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: liveProfit >= 0 ? Colors.green.shade200 : Colors.red.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              liveProfit >= 0
                                  ? "Estimated Profit (Sell - Buy):"
                                  : "Estimated Loss (Sell - Buy):",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: liveProfit >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                            Text(
                              "${liveProfit >= 0 ? '+' : '-'}৳${liveProfit.abs().toInt()}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: liveProfit >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isEditing) ...[
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: InputDecoration(
                            labelText: "স্ট্যাটাস",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: const [
                            DropdownMenuItem(value: "Available", child: Text("Available")),
                            DropdownMenuItem(value: "Sold", child: Text("Sold")),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedStatus = val);
                          },
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
                              foregroundColor: AppColors.primaryBlue,
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(source: ImageSource.gallery);
                              if (picked != null) {
                                final bytes = await picked.readAsBytes();
                                final uploadedUrl = await stockController.uploadImageToImgBB(
                                  bytes,
                                  picked.name,
                                );
                                if (uploadedUrl != null) {
                                  setDialogState(() => imageUrl = uploadedUrl);
                                }
                              }
                            },
                            icon: const Icon(Icons.image),
                            label: const Text("ছবি যুক্ত করুন"),
                          ),
                          const SizedBox(width: 10),
                          if (imageUrl.isNotEmpty)
                            const Expanded(
                              child: Text(
                                "ছবি সেট করা হয়েছে ✓",
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
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
                  onPressed: stockController.isLoading.value
                      ? null
                      : () {
                    if (formKey.currentState!.validate()) {
                      final double parsedBuy = double.parse(buyPriceCtrl.text.trim());
                      final double parsedSell = double.parse(sellPriceCtrl.text.trim());

                      if (isEditing) {
                        final updated = BikeModel(
                          id: existingBike.id,
                          brand: brandCtrl.text.trim(),
                          model: modelCtrl.text.trim(),
                          color: colorCtrl.text.trim(),
                          registration: regCtrl.text.trim(),
                          chassisNo: chassisCtrl.text.trim(),
                          engineNo: engineCtrl.text.trim(),
                          purchasePrice: parsedBuy,
                          sellingPrice: parsedSell,
                          status: selectedStatus,
                          imageUrl: imageUrl,
                          createdAt: existingBike.createdAt,
                        );
                        stockController.updateBike(updated);
                      } else {
                        final newBike = BikeModel(
                          brand: brandCtrl.text.trim(),
                          model: modelCtrl.text.trim(),
                          color: colorCtrl.text.trim(),
                          registration: regCtrl.text.trim(),
                          chassisNo: chassisCtrl.text.trim(),
                          engineNo: engineCtrl.text.trim(),
                          purchasePrice: parsedBuy,
                          sellingPrice: parsedSell,
                          status: 'Available',
                          imageUrl: imageUrl,
                          createdAt: DateTime.now(),
                        );
                        stockController.addBike(newBike);
                      }
                    }
                  },
                  child: stockController.isLoading.value
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