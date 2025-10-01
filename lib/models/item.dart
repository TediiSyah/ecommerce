// lib/models/item.dart
class Item {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final String? category;
  final int? stock;

  Item({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.category,
    this.stock,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'],
      description: json['description'],
      imageUrl: json['image_url'],
      category: json['category'],
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'stock': stock,
    };
  }
}
