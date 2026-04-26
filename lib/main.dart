import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:liquor_store_lk/screens/admin_orders_screen.dart';
import 'package:liquor_store_lk/screens/dmin_login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/cart_model.dart';
import 'screens/age_verification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/cart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID']!,
    ),
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const SupiriLiquorApp(),
    ),
  );
}

class SupiriLiquorApp extends StatelessWidget {
  const SupiriLiquorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liquor Store',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
      ),
      initialRoute: '/age_check',
      routes: {
        '/age_check': (context) => const AgeVerificationScreen(),
        '/home': (context) => const HomeScreen(),
        '/chat': (context) => const ChatScreen(),
        '/cart': (context) => const CartScreen(),
        '/admin': (context) => const AdminOrdersScreen(),
        '/admin_login': (context) => const AdminLoginScreen(),
      },
    );
  }
}
