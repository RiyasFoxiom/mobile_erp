import 'package:get/get.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ReportController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  // Date range variables
  final startDate = DateTime.now().subtract(const Duration(days: 7)).obs;
  final endDate = DateTime.now().obs;

  // Loading state
  final isLoading = false.obs;

  // Sales data
  final sales = <Map<String, dynamic>>[].obs;

  // Summary statistics
  final totalSales = 0.0.obs;
  final totalOrders = 0.obs;
  final totalDiscounts = 0.0.obs;
  final netTotal = 0.0.obs;

  // Stream subscription
  StreamSubscription? _salesSubscription;

  @override
  void onInit() {
    super.onInit();
    _fetchSalesData();
  }

  @override
  void onClose() {
    _salesSubscription?.cancel();
    super.onClose();
  }

  void updateDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    _fetchSalesData();
  }

  void _fetchSalesData() {
    // Cancel any existing subscription
    _salesSubscription?.cancel();

    isLoading.value = true;

    try {
      final salesStream = _firebaseService.getSalesByDateRange(
        startDate.value,
        endDate.value,
      );

      // Listen to the stream and update the UI when data arrives
      _salesSubscription = salesStream.listen(
        (salesData) {
          sales.value = salesData;
          _updateStats();
          isLoading.value = false;
        },
        onError: (error) {
          Get.snackbar(
            'Error',
            'Failed to fetch sales data: $error',
            snackPosition: SnackPosition.BOTTOM,
          );
          isLoading.value = false;
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to set up sales stream: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      isLoading.value = false;
    }
  }

  void _updateStats() {
    double total = 0;
    double discounts = 0;

    for (var sale in sales) {
      total += sale['totalAmount'] ?? 0;
      discounts += sale['discounts'] ?? 0;
    }

    totalSales.value = total;
    totalOrders.value = sales.length;
    totalDiscounts.value = discounts;
    netTotal.value = total - discounts;
  }

  String formatCurrency(double value) {
    return NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(value);
  }
}
