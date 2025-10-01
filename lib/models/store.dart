import 'dart:math' show sin, cos, sqrt, atan2;
import 'package:json_annotation/json_annotation.dart';

part 'store.g.dart';

@JsonSerializable(explicitToJson: true)
class Store {
  final String id;
  final String name;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String? phoneNumber;
  final String? email;
  final bool isOpen;
  final DateTime? openTime;
  final DateTime? closeTime;
  final double? deliveryRadius; // in kilometers

  Store({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.phoneNumber,
    this.email,
    this.isOpen = true,
    this.openTime,
    this.closeTime,
    this.deliveryRadius = 5.0, // Default 5km radius
  });

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
  Map<String, dynamic> toJson() => _$StoreToJson(this);

  // Helper method to calculate distance between two coordinates in kilometers
  double distanceTo(double lat, double lng) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    // Convert latitude and longitude from degrees to radians
    const double degreesToRadians = 0.017453292519943295; // PI / 180
    double lat1 = latitude * degreesToRadians;
    double lon1 = longitude * degreesToRadians;
    double lat2 = lat * degreesToRadians;
    double lon2 = lng * degreesToRadians;
    
    // Haversine formula
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double a = 
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  // Check if a location is within the store's delivery radius
  bool isWithinDeliveryRadius(double lat, double lng) {
    return distanceTo(lat, lng) <= (deliveryRadius ?? 5.0);
  }
}
