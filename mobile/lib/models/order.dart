class Order {
  final int id;
  final String productTitle;
  final String buyerName;
  final String farmerName;
  final double quantityKg;
  final double totalPrice;
  final double commission;
  final String status;
  final String message;
  final String createdAt;

  Order({
    required this.id,
    required this.productTitle,
    required this.buyerName,
    required this.farmerName,
    required this.quantityKg,
    required this.totalPrice,
    required this.commission,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      productTitle: json['product_title'] ?? '',
      buyerName: json['buyer_name'] ?? '',
      farmerName: json['farmer_name'] ?? '',
      quantityKg: double.tryParse(json['quantity_kg'].toString()) ?? 0,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
      commission: double.tryParse(json['commission'].toString()) ?? 0,
      status: json['status'] ?? 'pending',
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
