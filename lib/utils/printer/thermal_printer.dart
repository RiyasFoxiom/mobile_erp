import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:small_mobile_erp/utils/date_formate.dart';
import 'package:small_mobile_erp/utils/printer_widgets/printer_widgets.dart';

Future<List<int>> generateInvoice(Map<String, dynamic> saleData) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);

  List<int> bytes = [];

  // Header
  bytes += generator.text(
    "Invoice",
    styles: const PosStyles(
      align: PosAlign.center,
      bold: true,
    ),
  );

  bytes += generator.hr();

  // Invoice Info
  bytes += generator.row([
    PosColumn(
      text: "Invoice: ${saleData['invoiceNumber']}",
      width: 5,
      styles: const PosStyles(align: PosAlign.center),
    ),
     PosColumn(text: "      ", width: 2),
    PosColumn(
      text: "Date: ${DateFormatter.currentDateFormate(DateTime.parse(saleData['date']))}",
      width: 5,
      styles: const PosStyles(align: PosAlign.right),
    ),
  ]);

  bytes += generator.hr();

  // table heading
  bytes += generator.text(
      formatTableRow('Item', 'Qty', 'Price', 'Total'),
      styles: const PosStyles(align: PosAlign.left, bold: true));
  bytes += generator.hr();

  for (var product in saleData['items']) {
    // Split the product name into lines (max 25 characters per line)
    List<String> productNameLines =
        splitTextIntoLines(product['name'] ?? "", 20);

    // First line with table row data
    bytes += generator.text(
      formatTableRow(
        productNameLines.first, // First part of product name
        product['quantity'].toString(),
        product['price'].toString(),
        product['total'].toString(),
      ),
      styles: const PosStyles(align: PosAlign.left),
    );

    // Print additional lines of the product name
    for (var i = 1; i < productNameLines.length; i++) {
      bytes += generator.text(
        productNameLines[i], // Print remaining parts of product name
        styles: const PosStyles(align: PosAlign.left),
      );
    }
  }

  bytes += generator.hr();

  bytes += generator.emptyLines(1);

  bytes += generator.text(
    generateAlignedText("Total items : ${saleData['items'].length}",
        "Bill Total : ${saleData['subtotal'].toStringAsFixed(2)}"),
    styles: const PosStyles(bold: true, align: PosAlign.left),
  );

  // Updated invoice items generation
  final List<Map<String, String>> invoiceItems = [
    {
      "label": "Discount",
      "value": saleData['discounts'].toStringAsFixed(2)
    },
    {
      "label": "Net Amt",
      "value" :saleData['totalAmount'].toStringAsFixed(2),
    },
  ];

  for (var item in invoiceItems) {
    bytes += generator.text(
      generateRightAlignedText(item['label'] ?? "", item['value'] ?? ""),
      styles: const PosStyles(align: PosAlign.left),
    );
  }

   final netAmount = await convertTextToImage(
      text: "₹ ${saleData['totalAmount'].toStringAsFixed(2)}",
      fontSize: 45,
      fontWeight: FontWeight.bold);

  bytes += await convertImageForPrinting(netAmount, align: PosAlign.center);


  bytes += generator.hr();

  bytes += generator.text(
    "Thank you for your purchase!",
    styles: const PosStyles(align: PosAlign.center),
  );
  

  bytes += generator.emptyLines(3);

  return bytes;
}
