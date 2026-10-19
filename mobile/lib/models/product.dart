class Product {
  final int id;
  final String cropType;
  final String title;
  final String description;
  final double quantityKg;
  final double pricePerKg;
  final String region;
  final String woreda;
  final String status;
  final String farmerName;
  final String farmerPhone;
  final String? image;
  final String createdAt;

  Product({
    required this.id,
    required this.cropType,
    required this.title,
    required this.description,
    required this.quantityKg,
    required this.pricePerKg,
    required this.region,
    required this.woreda,
    required this.status,
    required this.farmerName,
    required this.farmerPhone,
    this.image,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      cropType: json['crop_type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      quantityKg: double.tryParse(json['quantity_kg'].toString()) ?? 0,
      pricePerKg: double.tryParse(json['price_per_kg'].toString()) ?? 0,
      region: json['region'] ?? '',
      woreda: json['woreda'] ?? '',
      status: json['status'] ?? 'available',
      farmerName: json['farmer_name'] ?? '',
      farmerPhone: json['farmer_phone'] ?? '',
      image: json['image'],
      createdAt: json['created_at'] ?? '',
    );
  }

  double get totalValue => quantityKg * pricePerKg;
}
