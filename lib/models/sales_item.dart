class SalesItem {
  String? name;
  int? quantity;
  double? price;
  double? discount;

  SalesItem({this.name, this.quantity, this.price, this.discount = 0});

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'price': price,
    'discount': discount,
  };
}
