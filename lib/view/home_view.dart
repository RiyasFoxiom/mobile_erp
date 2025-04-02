import 'package:flutter/material.dart';
import 'package:small_mobile_erp/view/sales_entry_view.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../view/sales_details_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            final newDate = controller.selectedDate.value
                                .subtract(const Duration(days: 1));
                            controller.selectedDate.value = newDate;
                            controller.updateDateDisplay();
                            controller.refreshData();
                          },
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Obx(
                          () => Text(
                            controller.dateDisplay.value,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            final now = DateTime.now();
                            final currentDate = controller.selectedDate.value;
                            if (currentDate.year == now.year &&
                                currentDate.month == now.month &&
                                currentDate.day == now.day) {
                              return;
                            }
                            controller.selectedDate.value = currentDate.add(
                              const Duration(days: 1),
                            );
                            controller.updateDateDisplay();
                            controller.refreshData();
                          },
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _buildStatCard(
                          'Today\'s Sales',
                          '₹${controller.todaySalesAmount.value.toStringAsFixed(2)}',
                          Icons.trending_up,
                          Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => _buildStatCard(
                          'Total Orders',
                          '${controller.todaySalesCount.value}',
                          Icons.shopping_cart,
                          Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _buildStatCard(
                          'Total Discount',
                          '₹${(controller.itemsDiscount.value + controller.finalDiscount.value).toStringAsFixed(2)}',
                          Icons.discount,
                          Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => _buildStatCard(
                          'Net Total',
                          '₹${controller.netTotal.value.toStringAsFixed(2)}',
                          Icons.account_balance_wallet,
                          Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Recent Sales Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Sales',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRecentSalesList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => SalesEntryView()));
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSalesList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.recentSales.isEmpty) {
        return const Center(child: Text('No recent sales'));
      }

      return Container(
        constraints: const BoxConstraints(
          maxHeight: 300,
        ), // Fixed height container
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(), // Enable scrolling
          itemCount: controller.recentSales.length,
          itemBuilder: (context, index) {
            final sale = controller.recentSales[index];
            return ListTile(
              title: Text(
                sale['invoiceNumber'] ?? 'No Invoice',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '₹${(sale['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(sale['items'] as List?)?.length ?? 0} items',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                Get.to(SalesDetailsView(sale: sale));
              },
            );
          },
        ),
      );
    });
  }
}
