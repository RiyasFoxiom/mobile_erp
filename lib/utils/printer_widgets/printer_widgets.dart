import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:image/image.dart' as img;

/// Splits a string into lines of specified width.
String formatTableRow(String desc, String qty, String price, String total) {
  String result = '';
  desc = desc.padRight(20).substring(0, 20); // Description: 20 chars
  qty = qty.padLeft(8).substring(0, 8); // Qty: 10 chars
  price = price.padLeft(10).substring(0, 10); // Price: 8 chars
  total = total.padLeft(10).substring(0, 10); // Total: 10 chars
  result = '$desc$qty$price$total';
  return result;
}

/// Splits a string into lines of specified width.
List<String> splitTextIntoLines(String text, int width) {
  List<String> lines = [];
  for (int i = 0; i < text.length; i += width) {
    lines.add(
      text.substring(i, i + width > text.length ? text.length : i + width),
    );
  }
  return lines;
}

String generateAlignedText(
  String leftText,
  String rightText, {
  int totalWidth = 48,
}) {
  int spaceBetween = totalWidth - (leftText.length + rightText.length);
  if (spaceBetween < 1) spaceBetween = 1; // Prevent negative spacing

  return leftText + " " * spaceBetween + rightText;
}
String generateRightAlignedText(String label, String value,
    {int totalWidth = 48, int labelWidth = 20}) {
  String colon = " : ";
  int labelMaxWidth =
      totalWidth - value.length - colon.length; // Remaining space for label
  String formattedLabel =
      label.padLeft(labelMaxWidth, ' '); // Ensure label is right-aligned

  return "$formattedLabel$colon$value"; // Aligns label, colon, and value properly
}


Future<ui.Image> convertTextToImage({
  required String text,
  double fontSize = 24,
  FontWeight fontWeight = FontWeight.bold,
  Color textColor = Colors.black,
  Color backgroundColor = Colors.white,
}) async {
  // Create a text painter
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    ),
    textDirection: TextDirection.ltr, // Important for Arabic text
    textAlign: TextAlign.center,
  )..layout();

  // Create a picture recorder
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Calculate image size
  // final imageWidth = textPainter.width.ceil() + 40; // Add padding
  // final imageHeight = textPainter.height.ceil() + 40; // Add padding
  final imageWidth = textPainter.width.ceil() + 1; // Add padding
  final imageHeight = textPainter.height.ceil() + 1; // Add padding

  // Create a background
  final paint = Paint()..color = backgroundColor;
  canvas.drawRect(
      Rect.fromLTWH(0, 0, imageWidth.toDouble(), imageHeight.toDouble()),
      paint);

  // Paint the text
  textPainter.paint(canvas, const Offset(0, 0)); // Add padding

  // End recording and convert to image
  final picture = recorder.endRecording();
  return await picture.toImage(imageWidth, imageHeight);
}



// Convert UI Image to printer-compatible format
Future<List<int>> convertImageForPrinting(
  ui.Image uiImage, {
  PosAlign align = PosAlign.center,
  bool isDoubleDensity = true,
}) async {
  // Create generator as a class property
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);
  // Convert ui.Image to byte data
  final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
  final uint8List = byteData!.buffer.asUint8List();

  // Decode the PNG bytes
  final image = img.decodeImage(uint8List);

  if (image == null) {
    throw Exception('Failed to decode image');
  }

  // Convert to black and white
  final bwImage = img.grayscale(image);

  // Use class generator method
  return generator.image(bwImage,
      align: align, isDoubleDensity: isDoubleDensity);
}