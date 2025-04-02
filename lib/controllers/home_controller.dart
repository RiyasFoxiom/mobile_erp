import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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

  // Stream subscription
  StreamSubscription<List<Map<String, dynamic>>>? _salesSubscription;

  @override
  void onInit() {
    super.onInit();
    updateDateDisplay();
    _initSalesStream();
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

  void _initSalesStream() {
    debugPrint('Initializing sales stream for date: ${selectedDate.value}');
    // Cancel existing subscription if any
    _salesSubscription?.cancel();
    
    isLoading.value = true;
    
    // Create new subscription
    _salesSubscription = _firebaseService
        .getSalesForDate(selectedDate.value)
        .listen(
          _updateStats,
          onError: (error) {
            debugPrint('Error in sales stream: $error');
            errorMessage.value = 'Error loading sales: $error';
            isLoading.value = false;
          },
        );
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
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    _initSalesStream();
  }

  @override
  void onClose() {
    _salesSubscription?.cancel();
    super.onClose();
  }
}
