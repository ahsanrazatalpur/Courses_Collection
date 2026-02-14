class User {
  final int? id;
  final String username;
  final String email;
  final String role;
  final bool isActive; // Active if not blocked
  final String? phone;    // Added
  final String? address;  // Added

  User({
    this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
    this.phone,
    this.address,
  });

  // Create a User instance from JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'user',
        isActive: !(json['is_blocked'] ?? false),
        phone: json['phone'],        // Added
        address: json['address'],    // Added
      );

  // Convert User instance to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'role': role,
        'is_blocked': !isActive,
        'phone': phone,       // Added
        'address': address,   // Added
      };

  // Copy method for easy updates (role, isActive, phone, address)
  User copyWith({
    String? role,
    bool? isActive,
    String? phone,
    String? address,
  }) {
    return User(
      id: id,
      username: username,
      email: email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
