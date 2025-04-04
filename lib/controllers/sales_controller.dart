import 'package:get/get.dart';
import 'package:small_mobile_erp/models/sales_item.dart';
import '../services/firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SalesController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  var items = <SalesItem>[SalesItem()].obs;
  var totalAmount = 0.0.obs;
  // var totalDiscount = 0.0.obs;
  var finalDiscount = 0.0.obs;
  var invoiceNumber = ''.obs;
  var isLoading = false.obs;
  var availableItems = <Map<String, dynamic>>[].obs;
  StreamSubscription? _itemsSubscription;
  // Track new items that need to be added to Firebase
  var newItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    generateInvoiceNumber();
    _setupItemsStream();
  }

  void _setupItemsStream() {
    _itemsSubscription = _firebaseService.getItems().listen(
      (itemsList) {
        availableItems.value = itemsList;
      },
      onError: (error) {
        debugPrint('Error fetching items: $error');
        Get.snackbar(
          'Error',
          'Failed to load items',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  void generateInvoiceNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (DateTime.now().millisecondsSinceEpoch % 1000)
        .toString()
        .padLeft(3, '0');

    invoiceNumber.value = 'INV-$year$month$day-$random';
  }

  // Reset the controller state when the view is reopened
  void resetState() {
    items.clear();
    items.add(SalesItem());
    totalAmount.value = 0.0;
    // totalDiscount.value = 0.0;
    finalDiscount.value = 0.0;
    newItems.clear(); // Clear new items when resetting
    generateInvoiceNumber();
  }

  Future<void> saveSaleEntry() async {
    try {
      // Validate items
      if (items.isEmpty) {
        Get.snackbar(
          'Error',
          'At least one item is required',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Validate required fields for each item
      for (var item in items) {
        if (item.name == null || item.name!.isEmpty) {
          Get.snackbar(
            'Error',
            'Product name is required',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        if (item.quantity == null || item.quantity! <= 0) {
          Get.snackbar(
            'Error',
            'Valid quantity is required',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        if (item.price == null || item.price! <= 0) {
          Get.snackbar(
            'Error',
            'Valid price is required',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      isLoading.value = true;
      
      // First, add any new items to Firebase
      for (var item in items) {
        if (item.name != null && item.name!.isNotEmpty) {
          // Check if this item exists in availableItems
          bool itemExists = availableItems.any((availableItem) => 
            availableItem['name'].toString().toLowerCase() == item.name!.toLowerCase()
          );
          
          if (!itemExists) {
            try {
              // Add the new item to Firebase
              final newItem = {
                'name': item.name,
                'createdAt': DateTime.now().millisecondsSinceEpoch,
              };
              await _firebaseService.addItem(newItem);
              debugPrint('Added new item to inventory: ${newItem['name']}');
            } catch (e) {
              debugPrint('Error adding new item to inventory: $e');
              // Continue with saving the sale even if adding a new item fails
            }
          }
        }
      }
      
      final saleData = {
        'invoiceNumber': invoiceNumber.value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'items':
            items
                .map(
                  (item) => {
                    'name': item.name ?? '',
                    'quantity': item.quantity ?? 0,
                    'price': item.price ?? 0,
                    // 'discount': item.discount ?? 0,
                    'total': (item.quantity ?? 0) * (item.price ?? 0),
                  },
                )
                .toList(),
        'subtotal': totalAmount.value,
        'discounts': finalDiscount.value,
        'totalAmount': finalTotal,
      };
      await _firebaseService.saveSaleEntry(saleData);
      resetState(); // Reset state after saving
      Get.back();
      Get.snackbar(
        'Success',
        'Sale entry saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save sale entry',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addItem() {
    items.add(SalesItem());
  }

  void removeItem(int index) {
    if (index > 0) {
      items.removeAt(index);
      calculateTotal();
    }
  }

  void updateItemName(int index, String value) {
    items[index].name = value;
    
    // Check if this is a new item that doesn't exist in availableItems
    bool itemExists = availableItems.any((item) => 
      item['name'].toString().toLowerCase() == value.toLowerCase()
    );
    
    // If it's a new item, add it to the newItems list for later saving
    if (!itemExists && value.isNotEmpty) {
      // Check if this item is already in the newItems list
      bool alreadyInNewItems = newItems.any((item) => 
        item['name'].toString().toLowerCase() == value.toLowerCase()
      );
      
      if (!alreadyInNewItems) {
        final newItem = {
          'name': value,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        };
        newItems.add(newItem);
        debugPrint('Added to new items list: ${newItem['name']}');
      }
    }
  }

  void updateItemQuantity(int index, String value) {
    items[index].quantity = int.tryParse(value) ?? 0;
    calculateTotal();
  }

  void updateItemPrice(int index, String value) {
    items[index].price = double.tryParse(value) ?? 0;
    calculateTotal();
  }

  // void updateItemDiscount(int index, String value) {
  //   // Make discount optional - if empty or invalid, set to 0
  //   items[index].discount = double.tryParse(value) ?? 0;
  //   calculateTotal();
  // }

  void updateFinalDiscount(String value) {
    // Make final discount optional - if empty or invalid, set to 0
    finalDiscount.value = double.tryParse(value) ?? 0;
    calculateTotal();
  }

  void calculateTotal() {
    double amount = 0;
    for (var item in items) {
      amount += (item.quantity ?? 0) * (item.price ?? 0);
      // discount += item.discount ?? 0;
    }
    totalAmount.value = amount;
    // totalDiscount.value = discount;
  }

  double get finalTotal => totalAmount.value - finalDiscount.value;

  @override
  void onClose() {
    resetState(); // Reset state when controller is closed
    _itemsSubscription?.cancel();
    super.onClose();
  }
}
