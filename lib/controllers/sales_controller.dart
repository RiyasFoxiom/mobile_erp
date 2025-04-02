import 'package:get/get.dart';
import 'package:small_mobile_erp/models/sales_item.dart';
import '../services/firebase_service.dart';

class SalesController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  var items = <SalesItem>[SalesItem()].obs;
  var totalAmount = 0.0.obs;
  var totalDiscount = 0.0.obs;
  var finalDiscount = 0.0.obs;
  var invoiceNumber = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    generateInvoiceNumber();
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
                    'discount': item.discount ?? 0,
                    'total':
                        (item.quantity ?? 0) * (item.price ?? 0) -
                        (item.discount ?? 0),
                  },
                )
                .toList(),
        'subtotal': totalAmount.value,
        'discounts': totalDiscount.value + finalDiscount.value,
        'totalAmount': finalTotal,
      };
      await _firebaseService.saveSaleEntry(saleData);
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
  }

  void updateItemQuantity(int index, String value) {
    items[index].quantity = int.tryParse(value) ?? 0;
    calculateTotal();
  }

  void updateItemPrice(int index, String value) {
    items[index].price = double.tryParse(value) ?? 0;
    calculateTotal();
  }

  void updateItemDiscount(int index, String value) {
    // Make discount optional - if empty or invalid, set to 0
    items[index].discount = double.tryParse(value) ?? 0;
    calculateTotal();
  }

  void updateFinalDiscount(String value) {
    // Make final discount optional - if empty or invalid, set to 0
    finalDiscount.value = double.tryParse(value) ?? 0;
    calculateTotal();
  }

  void calculateTotal() {
    double amount = 0;
    double discount = 0;
    for (var item in items) {
      amount += (item.quantity ?? 0) * (item.price ?? 0);
      discount += item.discount ?? 0;
    }
    totalAmount.value = amount;
    totalDiscount.value = discount;
  }

  double get finalTotal =>
      totalAmount.value - totalDiscount.value - finalDiscount.value;
}
