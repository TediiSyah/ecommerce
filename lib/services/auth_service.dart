// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/user.dart';

// Global HTTP client configuration
final _httpClientConfig = HttpClient()
  ..connectionTimeout = const Duration(seconds: 10)
  ..badCertificateCallback = (cert, host, port) => true; // Only for development!

class AuthService extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  String? _token;
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  String? get token => _token;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;
  bool get isStore => _user?.isStore ?? false;
  
  // Initialize with saved token if available
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      _user = User.fromJson(jsonDecode(userData));
    }
    notifyListeners();
  }

  // API base URL with direct connection
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api'; // Use direct URL for web
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://localhost:8000/api';
    }
  }

  // Get HTTP client with proper configuration
  Future<http.Client> get _client async {
    if (kIsWeb) {
      return http.Client();
    } else {
      return IOClient(_httpClientConfig);
    }
  }
  
  // Common headers for all requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };

  // Save auth data to shared preferences
  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(userData));
    _token = token;
    _user = User.fromJson(userData);
    notifyListeners();
  }

  // Create an HTTP client with better error handling
  http.Client get _httpClient {
    if (kIsWeb) {
      return http.Client();
    } else {
      // For mobile/desktop, use a client with a custom HttpClient
      final httpClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true; // Only for development!
      return IOClient(httpClient);
    }
  }

  // Register a new user with retry logic
  Future<User> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = await _client;
    final url = Uri.parse('${_baseUrl}/register');
    
    try {
      debugPrint('Sending registration request to: $url');
      
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      ).timeout(const Duration(seconds: 10));

      debugPrint('Register - Status: ${response.statusCode}');
      debugPrint('Register - Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseData['token'] == null || responseData['user'] == null) {
          throw Exception('Invalid response format: Missing token or user data');
        }
        await _saveAuthData(responseData['token'], responseData['user']);
        return _user!;
      } else {
        String errorMessage = 'Registration failed';
        try {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorData['message'] ?? 
                      errorData['error'] ?? 
                      errorData.toString();
          if (errorData['errors'] != null) {
            errorMessage += '\n' + errorData['errors'].toString();
          }
        } catch (_) {
          errorMessage = 'Server error: ${response.statusCode} - ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      _error = 'Network error: ${e.message}. Please check your connection.';
      rethrow;
    } on FormatException catch (e) {
      _error = 'Invalid response format: $e';
      rethrow;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      client.close();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<User> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final client = _httpClient;
      
      try {
        final response = await client.post(
          Uri.parse('${_baseUrl}/login'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        ).timeout(const Duration(seconds: 10));

        debugPrint('Login - Status: ${response.statusCode}');
        debugPrint('Login - Body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(utf8.decode(response.bodyBytes));
          if (responseData['token'] == null || responseData['user'] == null) {
            throw Exception('Invalid response format: Missing token or user data');
          }
          await _saveAuthData(responseData['token'], responseData['user']);
          return _user!;
        } else {
          String errorMessage = 'Login failed';
          try {
            final errorData = jsonDecode(utf8.decode(response.bodyBytes));
            errorMessage = errorData['message'] ?? errorData.toString();
          } catch (_) {
            errorMessage = 'Server error: ${response.statusCode} - ${response.body}';
          }
          throw Exception(errorMessage);
        }
      } finally {
        client.close();
      }
    } on http.ClientException catch (e) {
      _error = 'Network error: ${e.message}. Please check your connection.';
      rethrow;
    } on FormatException catch (e) {
      _error = 'Invalid response format: $e';
      rethrow;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    _token = null;
    _user = null;
    notifyListeners();
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    await init();
    return _token != null;
  }
}
