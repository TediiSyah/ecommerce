import 'package:flutter/foundation.dart';
import 'item.dart';

class CartItem {
  final Item item;
  int quantity;

  CartItem({
    required this.item,
    this.quantity = 1,
  });

  double get totalPrice => item.price * quantity;

  CartItem copyWith({
    int? quantity,
  }) {
    return CartItem(
      item: item,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Cart extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  String? _storeId;
  String? _storeName;

  Map<String, CartItem> get items => Map.unmodifiable(_items);
  String? get storeId => _storeId;
  String? get storeName => _storeName;
  int get itemCount => _items.length;
  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Set the store for the cart
  void setStore(String storeId, String storeName) {
    if (_storeId != storeId) {
      // Clear cart if changing stores
      _items.clear();
      _storeId = storeId;
      _storeName = storeName;
      notifyListeners();
    }
  }

  // Add an item to the cart
  void addItem(Item item, {int quantity = 1}) {
    if (quantity <= 0) return;

    if (_items.containsKey(item.id)) {
      _items.update(
        item.id.toString(),
        (existingItem) => existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        ),
      );
    } else {
      _items[item.id.toString()] = CartItem(
        item: item,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  // Remove an item from the cart
  void removeItem(dynamic itemId) {
    final itemIdStr = itemId.toString();
    if (!_items.containsKey(itemIdStr)) return;
    _items.remove(itemIdStr);
    // Clear store if cart is empty
    if (_items.isEmpty) {
      _storeId = null;
      _storeName = null;
    }
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(String itemId, int quantity) {
    if (!_items.containsKey(itemId) || quantity <= 0) return;
    
    _items.update(
      itemId,
      (existingItem) => existingItem.copyWith(quantity: quantity),
    );
    notifyListeners();
  }

  // Clear the cart
  void clear() {
    _items.clear();
    _storeId = null;
    _storeName = null;
    notifyListeners();
  }

  // Check if cart is empty
  bool get isEmpty => _items.isEmpty;

  // Check if cart is not empty
  bool get isNotEmpty => _items.isNotEmpty;

  // Get a list of cart items
  List<CartItem> get itemsList => _items.values.toList();

  // Convert cart to order items
  List<Map<String, dynamic>> toOrderItems() {
    return _items.values.map((cartItem) {
      return {
        'itemId': cartItem.item.id,
        'name': cartItem.item.name,
        'imageUrl': cartItem.item.imageUrl,
        'quantity': cartItem.quantity,
        'price': cartItem.item.price,
      };
    }).toList();
  }
}
