import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'routes.dart';
import 'screens/dashboard_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByteBank',
      initialRoute: Routes.dashboard,
      routes: {
        Routes.welcome: (context) => const WelcomeScreen(),
        Routes.dashboard: (context) => const DashboardScreen(),
      },
    );
  }
}
