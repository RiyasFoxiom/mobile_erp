class SaleItem {
  final String name;
  final double quantity;
  final double price;
  final double discount;
  final double total;

  SaleItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.total,
  });

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      name: map['name'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      price: (map['price'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'total': total,
    };
  }
} 