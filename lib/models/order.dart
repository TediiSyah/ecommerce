import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

part 'order.g.dart';

enum OrderStatus {
  pending,
  processing,
  readyForPickup,
  completed,
  cancelled,
}

@JsonSerializable()
class Order {
  final String id;
  final String userId;
  final String storeId;
  final String storeName;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double userLatitude;
  final double userLongitude;
  final String? userAddress;
  final double storeLatitude;
  final double storeLongitude;
  final String storeAddress;

  Order({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.storeName,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.updatedAt,
    required this.userLatitude,
    required this.userLongitude,
    this.userAddress,
    required this.storeLatitude,
    required this.storeLongitude,
    required this.storeAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson({
        ...json,
        'status': OrderStatus.values.firstWhereOrNull(
                (e) => e.toString() == 'OrderStatus.${json['status']}') ??
            OrderStatus.pending,
      });

  Map<String, dynamic> toJson() => {
        ..._$OrderToJson(this),
        'status': status.toString().split('.').last,
      };

  Order copyWith({
    OrderStatus? status,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id,
      userId: userId,
      storeId: storeId,
      storeName: storeName,
      items: items,
      totalAmount: totalAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      userAddress: userAddress,
      storeLatitude: storeLatitude,
      storeLongitude: storeLongitude,
      storeAddress: storeAddress,
    );
  }
}

@JsonSerializable()
class OrderItem {
  final String itemId;
  final String name;
  final String? imageUrl;
  final int quantity;
  final double price;

  OrderItem({
    required this.itemId,
    required this.name,
    this.imageUrl,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  OrderItem copyWith({
    int? quantity,
  }) {
    return OrderItem(
      itemId: itemId,
      name: name,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
      price: price,
    );
  }
}
