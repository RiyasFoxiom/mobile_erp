import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:intl/intl.dart';

class SalesDetailsView extends StatelessWidget {
  final Map<String, dynamic> sale;

  const SalesDetailsView({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = sale['items'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sale Details - ${sale['invoiceNumber']}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sale Summary Card
              Card(
                elevation: 2,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invoice: ${sale['invoiceNumber']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy, HH:mm',
                                ).format(DateTime.fromMillisecondsSinceEpoch(sale['timestamp'])),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _buildSummaryRow(
                        'Subtotal',
                        (sale['subtotal'] ?? 0.0).toDouble(),
                        Colors.blue[700]!,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        'Discount',
                        ((sale['discounts'] ?? 0.0) + (sale['finalDiscount'] ?? 0.0)).toDouble(),
                        Colors.blue[700]!,
                      ),
                      const Divider(height: 32),
                      _buildSummaryRow(
                        'Net Total',
                        (sale['totalAmount'] ?? 0.0).toDouble(),
                        Colors.blue[700]!,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Products Table
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 24,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  height: 400,
                  child: SfDataGridTheme(
                    data: SfDataGridThemeData(
                      headerColor: Colors.blue[50],
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
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: Text(
                              'Product Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          width: 200,
                        ),
                        GridColumn(
                          columnName: 'quantity',
                          label: Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: Text(
                              'Quantity',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          width: 100,
                        ),
                        GridColumn(
                          columnName: 'price',
                          label: Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: Text(
                              'Price',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          width: 120,
                        ),
                        GridColumn(
                          columnName: 'discount',
                          label: Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: Text(
                              'Discount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          width: 120,
                        ),
                        GridColumn(
                          columnName: 'total',
                          label: Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          width: 120,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value,
    Color color, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
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
            columnName: 'discount',
            value: (item['discount'] ?? 0.0).toDouble(),
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
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: Text(
            displayValue,
            style: const TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
    );
  }
}
