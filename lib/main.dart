// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/user/home_screen_new.dart';
import 'screens/user/item_list_screen.dart';
import 'screens/user/checkout_screen.dart';
import 'screens/store/dashboard_screen.dart';
import 'screens/store/store_orders_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully');
  } catch (e) {
    print('Error loading .env file: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..init()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize auth service and print initial state
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.init().then((_) {
      print(
          'Initial auth state - isAuthenticated: ${authService.isAuthenticated}, isStore: ${authService.isStore}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    print(
        'Building app with isAuthenticated: ${authService.isAuthenticated}, isStore: ${authService.isStore}');

    return MaterialApp(
      title: 'Supermarket App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/user/home': (context) => const HomeScreen(),
        '/user/items': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final category = args?['category'] ?? 'all';
          return ItemListScreen(category: category);
        },
        '/user/checkout': (context) => const CheckoutScreen(),
        '/store/dashboard': (context) => const DashboardScreen(),
        '/store/orders': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final category = args?['category'] ?? 'all';
          return StoreOrdersScreen(category: category);
        },
      },
      onGenerateRoute: (settings) {
        // Handle any other routes here
        return null;
      },
      home: Consumer<AuthService>(
        builder: (context, authService, _) {
          if (authService.isAuthenticated) {
            return authService.isStore
                ? const DashboardScreen()
                : const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
