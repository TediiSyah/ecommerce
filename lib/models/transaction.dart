// lib/models/transaction.dart
import 'package:supermaket_app/models/user.dart';
import 'package:supermaket_app/models/item.dart';

class Transaction {
  final int id;
  final int userId;
  final int storeId;
  final int itemId;
  final int quantity;
  final double totalPrice;
  final String status;
  final double userLongLocation;
  final double userLatLocation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Item? item;
  final User? store;
  final User? user;

  Transaction({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.itemId,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.userLongLocation,
    required this.userLatLocation,
    required this.createdAt,
    required this.updatedAt,
    this.item,
    this.store,
    this.user,
  });

  // Status constants
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_APPROVED = 'approved';
  static const String STATUS_REJECTED = 'rejected';
  static const String STATUS_COMPLETED = 'completed';

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      storeId: json['store_id'],
      itemId: json['item_id'],
      quantity: json['quantity'],
      totalPrice: json['total_price'] is int
          ? (json['total_price'] as int).toDouble()
          : json['total_price'],
      status: json['status'],
      userLongLocation: json['user_long_location'] is String
          ? double.parse(json['user_long_location'])
          : json['user_long_location'] is int
              ? (json['user_long_location'] as int).toDouble()
              : json['user_long_location'],
      userLatLocation: json['user_lat_location'] is String
          ? double.parse(json['user_lat_location'])
          : json['user_lat_location'] is int
              ? (json['user_lat_location'] as int).toDouble()
              : json['user_lat_location'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      item: json['item'] != null ? Item.fromJson(json['item']) : null,
      store: json['store'] != null ? User.fromJson(json['store']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'store_id': storeId,
      'item_id': itemId,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': status,
      'user_long_location': userLongLocation,
      'user_lat_location': userLatLocation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'item': item?.toJson(),
      'store': store?.toJson(),
      'user': user?.toJson(),
    };
  }
}
