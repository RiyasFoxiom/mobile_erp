import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:small_mobile_erp/controllers/sales_controller.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:intl/intl.dart';

class SalesDetailsView extends StatelessWidget {
  final Map<String, dynamic> sale;

  const SalesDetailsView({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = sale['items'] ?? [];


    final controller  = Get.find<SalesController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Invoice #${sale['invoiceNumber']}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              controller.printReceipt(sale);
            },
            icon: const Icon(Icons.print),
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(sale['timestamp']),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAmountCard(),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Items Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Items (${items.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildItemsTable(items),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildAmountRow(
            'Subtotal',
            (sale['subtotal'] ?? 0.0).toDouble(),
            isTotal: false,
          ),
          const SizedBox(height: 12),
          _buildAmountRow(
            'Discount',
            ((sale['discounts'] ?? 0.0)).toDouble(),
            isTotal: false,
            isDiscount: true,
          ),
          const Divider(height: 24),
          _buildAmountRow(
            'Net Total',
            (sale['totalAmount'] ?? 0.0).toDouble(),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    double value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDiscount ? Colors.red[700] : Colors.grey[700],
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: isDiscount ? Colors.red[700] : Colors.grey[800],
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTable(List<dynamic> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: SfDataGridTheme(
        data: SfDataGridThemeData(
          headerColor: Colors.grey[100],
          gridLineColor: Colors.grey[200],
          gridLineStrokeWidth: 1,
        ),
        child: SfDataGrid(
          source: SaleItemsDataSource(items),
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          horizontalScrollPhysics: const BouncingScrollPhysics(),
          verticalScrollPhysics: const BouncingScrollPhysics(),
          columns: [
            GridColumn(
              columnName: 'name',
              label: Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Product',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              width: 150,
            ),
            GridColumn(
              columnName: 'quantity',
              label: Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                child: Text(
                  'Qty',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              width: 80,
            ),
            GridColumn(
              columnName: 'price',
              label: Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.centerRight,
                child: Text(
                  'Price',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              width: 100,
            ),
           
            GridColumn(
              columnName: 'total',
              label: Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.centerRight,
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              width: 100,
            ),
          ],
        ),
      ),
    );
  }
}

class SaleItemsDataSource extends DataGridSource {
  SaleItemsDataSource(List<dynamic> items) {
    dataGridRows = items.map<DataGridRow>((item) {
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'name', value: item['name'] ?? ''),
          DataGridCell<double>(
            columnName: 'quantity',
            value: (item['quantity'] ?? 0.0).toDouble(),
          ),
          DataGridCell<double>(
            columnName: 'price',
            value: (item['price'] ?? 0.0).toDouble(),
          ),
          
          DataGridCell<double>(
            columnName: 'total',
            value: (item['total'] ?? 0.0).toDouble(),
          ),
        ],
      );
    }).toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        final value = cell.value;
        String displayValue = value.toString();

        if (value is double) {
          if (cell.columnName == 'quantity') {
            displayValue = value.toStringAsFixed(0);
          } else {
            displayValue = NumberFormat.currency(
              symbol: '₹',
              decimalDigits: 2,
            ).format(value);
          }
        }

        return Container(
          alignment: cell.columnName == 'name' 
              ? Alignment.centerLeft 
              : Alignment.centerRight,
          padding: const EdgeInsets.all(12),
          child: Text(
            displayValue,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 13,
            ),
          ),
        );
      }).toList(),
    );
  }
}
