import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/items_controller.dart';

// class ItemsAddingView extends GetView<ItemsController> {
class ItemsAddingView extends StatelessWidget {
  final controller = Get.put(ItemsController());

  ItemsAddingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      // drawer: AppDrawer(),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,

        title: Text(
          'Items Management',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F7FA)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Add Item Section
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildItemForm(),
                  ],
                ),
              ),

              // Items List
              SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Text(
                              'Items List',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Obx(
                          () =>
                              controller.items.isEmpty
                                  ? _buildEmptyState()
                                  : _buildItemsList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemForm() {
    return Column(
      children: [
        TextFormField(
          controller: controller.itemNameController,
          decoration: InputDecoration(
            labelText: 'Item Name',
            labelStyle: TextStyle(color: Color(0xFF5F6368), fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF1A73E8)),
            ),
            filled: true,
            fillColor: Color(0xFFF8F9FA),
            prefixIcon: Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF5F6368),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onFieldSubmitted: (_) => controller.addItem(),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: controller.addItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1A73E8),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 45),
            elevation: 0,
          ),
          child: Text(
            'Add Item',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFE8F0FE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Color(0xFF1A73E8),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first item to get started',
            style: TextStyle(fontSize: 14, color: Color(0xFF5F6368)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: controller.items.length,
      itemBuilder: (context, index) {
        final item = controller.items[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(item['name']),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () => controller.showDeleteConfirmation(item['id']),
            ),
          ),
        );
      },
    );
  }
}
