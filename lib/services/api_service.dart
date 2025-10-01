// lib/services/api_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({this.data, this.error, this.statusCode});

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;
  bool get hasError => error != null;
}

class ApiService {
  static String get baseUrl =>
      dotenv.get('API_URL', fallback: 'http://10.0.2.2:8000/api');

  static Future<Map<String, String>> _getHeaders({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static dynamic _handleResponse(http.Response response) {
    try {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode >= 400) {
        throw responseData['message']?.toString() ?? 'Something went wrong';
      }
      
      return responseData;
    } catch (e) {
      throw 'Failed to parse response: $e';
    }
  }

  // Auth Endpoints
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _getHeaders(auth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> register(
    String name, 
    String email, 
    String password, 
    String role, {
    String? storeName,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _getHeaders(auth: false),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
        'store_name': storeName,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      }..removeWhere((key, value) => value == null)),
    );
    return _handleResponse(response);
  }

  // Store Endpoints
  static Future<List<dynamic>> getNearbyStores(double lat, double lng, {double radius = 5.0}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stores/nearby?lat=$lat&lng=$lng&radius=$radius'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getStoreItems(String storeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stores/$storeId/items'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  // Item Endpoints
  static Future<List<dynamic>> searchItems(String query, {String? storeId}) async {
    String url = '$baseUrl/items/search?q=$query';
    if (storeId != null) {
      url += '&store_id=$storeId';
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  // Order Endpoints
  static Future<Map<String, dynamic>> createOrder({
    required String storeId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required double userLat,
    required double userLng,
    String? userAddress,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'store_id': storeId,
        'items': items,
        'total_amount': totalAmount,
        'user_latitude': userLat,
        'user_longitude': userLng,
        'user_address': userAddress,
      }),
    );
    return _handleResponse(response);
  }

  static Future<List<dynamic>> getUserOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/my-orders'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<List<dynamic>> getStoreOrders(String storeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stores/$storeId/orders'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
    String orderId, 
    String status,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );
    return _handleResponse(response);
  }

  // Location Helper
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }
    
    // Get current position
    return await Geolocator.getCurrentPosition();
  }
}
