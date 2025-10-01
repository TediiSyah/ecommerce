import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supermaket_app/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static const String baseUrl = 'http://your-api-url/api'; // Replace with your actual API URL
  
  // Create a new order
  static Future<Map<String, dynamic>> createOrder(Order order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create order: ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating order: $e',
      };
    }
  }

  // Add more order-related methods here as needed
  // For example: getOrderById, getOrderHistory, updateOrderStatus, etc.
}
