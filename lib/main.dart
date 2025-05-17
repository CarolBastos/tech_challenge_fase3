// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:tech_challenge_fase3/app_state.dart';
import 'package:tech_challenge_fase3/provider/transaction_provider.dart';
import 'package:tech_challenge_fase3/screens/login_screen.dart';
import 'package:tech_challenge_fase3/screens/register_screen.dart';
import 'routes.dart';
import 'screens/dashboard_screen.dart';
import 'screens/welcome_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart'; // Mantido para TransactionProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('pt_BR', null);

  // Criação do store Redux
  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [thunkMiddleware],
  );

  runApp(
    MultiProvider(
      providers: [
        // Provider do Redux
        // Mantemos o TransactionProvider como estava, pois não foi migrado para Redux
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
      ],
      child: StoreProvider<AppState>(store: store, child: const MyApp()),
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
