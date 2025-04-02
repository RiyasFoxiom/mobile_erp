import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  // Observable variables
  final isLoading = false.obs;
  final recentSales = <Map<String, dynamic>>[].obs;
  final todaySalesCount = 0.obs;
  final todaySalesAmount = 0.0.obs;
  final itemsDiscount = 0.0.obs;
  final finalDiscount = 0.0.obs;
  final netTotal = 0.0.obs;
  final errorMessage = ''.obs;
  final selectedDate = DateTime.now().obs;
  final dateDisplay = ''.obs;

  @override
  void onInit() {
    super.onInit();
    updateDateDisplay();
    refreshData();
  }

  void updateDateDisplay() {
    final now = DateTime.now();
    final selected = selectedDate.value;
    
    if (selected.year == now.year && 
        selected.month == now.month && 
        selected.day == now.day) {
      dateDisplay.value = 'Today';
    } else if (selected.year == now.year && 
               selected.month == now.month && 
               selected.day == now.day - 1) {
      dateDisplay.value = 'Yesterday';
    } else {
      dateDisplay.value = DateFormat('dd MMM').format(selected);
    }
  }

  Future<void> refreshData() async {
    debugPrint('Refreshing data for date: ${selectedDate.value}');
    isLoading.value = true;
    try {
      final sales = await _firebaseService.getSalesForDate(selectedDate.value).first;
      _updateStats(sales);
    } catch (e) {
      debugPrint('Error refreshing data: $e');
      errorMessage.value = 'Error refreshing data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _updateStats(List<Map<String, dynamic>> sales) {
    try {
      double totalAmount = 0;
      double totalDiscount = 0;
      double totalFinalDiscount = 0;

      for (var sale in sales) {
        totalAmount += (sale['totalAmount'] ?? 0.0).toDouble();
        totalDiscount += (sale['discounts'] ?? 0.0).toDouble();
        totalFinalDiscount += (sale['finalDiscount'] ?? 0.0).toDouble();
      }

      todaySalesCount.value = sales.length;
      todaySalesAmount.value = totalAmount;
      itemsDiscount.value = totalDiscount;
      finalDiscount.value = totalFinalDiscount;
      netTotal.value = totalAmount - totalDiscount - totalFinalDiscount;
      recentSales.value = sales;

      debugPrint('''
        Updated stats for ${dateDisplay.value}:
        - Sales count: ${sales.length}
        - Total amount: $totalAmount
        - Discounts: $totalDiscount
        - Final discount: $totalFinalDiscount
        - Net total: ${netTotal.value}
      ''');
    } catch (e) {
      debugPrint('Error updating stats: $e');
      errorMessage.value = 'Error updating stats: $e';
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
