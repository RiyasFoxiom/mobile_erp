import 'sale_item.dart';

class Sale {
  final String id;
  final String invoiceNumber;
  final DateTime timestamp;
  final double subtotal;
  final double discounts;
  final double finalDiscount;
  final double totalAmount;
  final List<SaleItem> items;

  Sale({
    required this.id,
    required this.invoiceNumber,
    required this.timestamp,
    required this.subtotal,
    required this.discounts,
    required this.finalDiscount,
    required this.totalAmount,
    required this.items,
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    DateTime getDateTime(dynamic timestamp) {
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
      return DateTime.now();
    }

    return Sale(
      id: map['id'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      timestamp: getDateTime(map['timestamp']),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      discounts: (map['discounts'] ?? 0.0).toDouble(),
      finalDiscount: (map['finalDiscount'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => SaleItem.fromMap(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'subtotal': subtotal,
      'discounts': discounts,
      'finalDiscount': finalDiscount,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}

// class SaleItem {
//   final String name;
//   final num quantity;
//   final num price;
//   final num? discount;
//   final num total;

//   SaleItem({
//     required this.name,
//     required this.quantity,
//     required this.price,
//     this.discount,
//     required this.total,
//   });

//   factory SaleItem.fromJson(Map<String, dynamic> json) {
//     return SaleItem(
//       name: json['name'] ?? '',
//       quantity: (json['quantity'] ?? 0.0).tonum(),
//       price: (json['price'] ?? 0.0).tonum(),
//       discount: (json['discount'] ?? 0.0).tonum(),
//       total: (json['total'] ?? 0.0).tonum(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'quantity': quantity,
//       'price': price,
//       'discount': discount,
//       'total': total,
//     };
//   }
// }
