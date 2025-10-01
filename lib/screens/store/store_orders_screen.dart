import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class StoreOrdersScreen extends StatefulWidget {
  final String category;
  
  const StoreOrdersScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  _StoreOrdersScreenState createState() => _StoreOrdersScreenState();
}

class _StoreOrdersScreenState extends State<StoreOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.user;
      
      if (currentUser == null) {
        throw 'User not authenticated. Please log in.';
      }
      
      if (!currentUser.isStore) {
        throw 'Only store owners can view store orders.';
      }
      
      // Call the static getStoreOrders method with the storeId (user's id for store owners)
      final List<dynamic> orders = await ApiService.getStoreOrders(currentUser.id.toString());
      
      // Filter orders by category if needed
      List<dynamic> filteredResponse = orders;
      if (widget.category != 'all') {
        // Filter orders by category if specified
        filteredResponse = orders.where((order) => order['category'] == widget.category).toList();
      }
      
      setState(() {
        _orders = filteredResponse.map((order) => Order.fromJson(order)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load orders: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Orders'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _orders.isEmpty
                  ? const Center(child: Text('No orders found'))
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text('Order #${order.id}'),
                            subtitle: Text(
                                '${order.items.length} items · ${order.status}'),
                            trailing: Text('\$${order.totalAmount.toStringAsFixed(2)}'),
                            onTap: () {
                              // Navigate to order details
                              // Navigator.pushNamed(context, '/order/details', arguments: order.id);
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
