// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String? storeName;
  final double? latitude;
  final double? longitude;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.storeName,
    this.latitude,
    this.longitude,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      storeName: json['store_name'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'store_name': storeName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  bool get isStore => role == 'store';
}
