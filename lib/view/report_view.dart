import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:small_mobile_erp/view/sales_details_view.dart';
import '../controllers/report_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Sales Report',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: Icon(Icons.menu_rounded),
        ),
      ),
      body: Column(
        children: [
          // _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangePicker(),
                  const SizedBox(height: 12),
                  _buildSummaryCards(),
                  const SizedBox(height: 12),
                  _buildSalesChart(),
                  const SizedBox(height: 12),
                  _buildSalesList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    'From: ${DateFormat('MMM dd, yyyy').format(controller.startDate.value)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    'To: ${DateFormat('MMM dd, yyyy').format(controller.endDate.value)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            onPressed: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: Get.context!,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(
                  start: controller.startDate.value,
                  end: controller.endDate.value,
                ),
              );
              if (picked != null) {
                controller.updateDateRange(picked.start, picked.end);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(
      () =>
          controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Sales',
                          controller.formatCurrency(
                            controller.totalSales.value,
                          ),
                          Icons.attach_money,
                          const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          'Orders',
                          controller.totalOrders.value.toString(),
                          Icons.shopping_cart,
                          const Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Discounts',
                          controller.formatCurrency(
                            controller.totalDiscounts.value,
                          ),
                          Icons.discount,
                          const Color(0xFFFF9800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          'Net Total',
                          controller.formatCurrency(controller.netTotal.value),
                          Icons.account_balance_wallet,
                          const Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sales Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Obx(
                () => Text(
                  'Total: ${controller.formatCurrency(controller.totalSales.value)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.sales.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No sales data available',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              // Group sales by date
              final Map<String, double> dailySales = {};
              for (var sale in controller.sales) {
                final timestamp = DateTime.fromMillisecondsSinceEpoch(
                  sale['timestamp'],
                );
                final dateKey = DateFormat('MMM dd').format(timestamp);
                final amount = (sale['totalAmount'] ?? 0.0).toDouble();
                dailySales[dateKey] = (dailySales[dateKey] ?? 0) + amount;
              }

              // Create data points for the chart
              final List<SalesData> chartData = [];

              // Get the date range
              final startDate = controller.startDate.value;
              final endDate = controller.endDate.value;

              // Generate all dates in the range
              for (
                var date = startDate;
                date.isBefore(endDate.add(const Duration(days: 1)));
                date = date.add(const Duration(days: 1))
              ) {
                final dateKey = DateFormat('MMM dd').format(date);
                chartData.add(SalesData(dateKey, dailySales[dateKey] ?? 0));
              }

              return SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 11),
                  majorGridLines: const MajorGridLines(width: 0),
                  interval: 1, // Show every date
                  labelRotation: 45, // Rotate labels for better readability
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 11),
                  numberFormat: NumberFormat.currency(
                    symbol: '₹',
                    decimalDigits: 0,
                  ),
                  majorGridLines: MajorGridLines(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                plotAreaBorderWidth: 0,
                series: <CartesianSeries<SalesData, String>>[
                  ColumnSeries<SalesData, String>(
                    dataSource: chartData,
                    xValueMapper: (SalesData sales, _) => sales.hour,
                    yValueMapper: (SalesData sales, _) => sales.amount,
                    color: Colors.blue[400],
                    borderRadius: BorderRadius.circular(4),
                    animationDuration: 1000,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  builder: (
                    dynamic data,
                    dynamic point,
                    dynamic series,
                    int pointIndex,
                    int seriesIndex,
                  ) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${point.x}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(
                              symbol: '₹',
                              decimalDigits: 0,
                            ).format(point.y),
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sales List',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Obx(
                () => Text(
                  '${controller.sales.length} orders',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.sales.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'No sales found for this date range',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              );
            }

            return Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: controller.sales.length,
                itemBuilder: (context, index) {
                  final sale = controller.sales[index];

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => SalesDetailsView(sale: sale));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: Color(0xFF2196F3),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Invoice #${sale['invoiceNumber'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  "${sale["items"].length} items",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${(sale['totalAmount'] ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.hour, this.amount);
  final String hour;
  final double amount;
}
