import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';
import 'dart:async';

class ItemsController extends GetxController {
  final itemNameController = TextEditingController();
  final items = <Map<String, dynamic>>[].obs;
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _itemsSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupItemsStream();
  }

  void _setupItemsStream() {
    _itemsSubscription = _firebaseService.getItems().listen(
      (itemsList) {
        items.value = itemsList;
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

  @override
  void onClose() {
    itemNameController.dispose();
    _itemsSubscription?.cancel();
    super.onClose();
  }

  Future<void> addItem() async {
    if (itemNameController.text.isEmpty) return;

    try {
      await _firebaseService.addItem({
        'name': itemNameController.text,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      itemNameController.clear();
    } catch (e) {
      debugPrint('Error adding item: $e');
      Get.snackbar(
        'Error',
        'Failed to add item',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _firebaseService.deleteItem(id);
    } catch (e) {
      debugPrint('Error deleting item: $e');
      Get.snackbar(
        'Error',
        'Failed to delete item',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showDeleteConfirmation(String? itemId) {
    if (itemId == null) return;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Item',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: Text(
          'Are you sure you want to delete this item?',
          style: TextStyle(fontSize: 16, color: Color(0xFF5F6368)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF5F6368), fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteItem(itemId);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFDC3545),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
