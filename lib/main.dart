import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_fase3/provider/transaction_provider.dart';
import 'package:tech_challenge_fase3/screens/login_screen.dart';
import 'package:tech_challenge_fase3/screens/register_screen.dart';
import 'package:tech_challenge_fase3/models/user_model.dart';
import 'routes.dart';
import 'screens/dashboard_screen.dart';
import 'screens/welcome_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserModel()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByteBank',
      initialRoute: Routes.login,
      routes: {
        Routes.welcome: (context) => const WelcomeScreen(),
        Routes.dashboard: (context) => DashboardScreen(),
        Routes.register: (context) => const RegisterScreen(),
        Routes.login: (context) => const LoginScreen(),
      },
    );
  }
}
