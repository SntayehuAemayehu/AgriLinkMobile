class Farmer {
  final int id;
  final String username;
  final String phone;
  final String role;
  final String region;
  final String woreda;
  final String firstName;
  final String lastName;
  final bool isVerified;

  Farmer({
    required this.id,
    required this.username,
    required this.phone,
    required this.role,
    required this.region,
    required this.woreda,
    required this.firstName,
    required this.lastName,
    required this.isVerified,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'farmer',
      region: json['region'] ?? '',
      woreda: json['woreda'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isVerified: json['is_verified'] ?? false,
    );
  }
}
