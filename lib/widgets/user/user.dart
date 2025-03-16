import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String _displayName = "Usuário";
  double _balance = 0.0;

  String get displayName => _displayName;
  double get balance => _balance;

  void updateUser(String name, double balance) {
    _displayName = name;
    _balance = balance;
    notifyListeners(); // Notifica os ouvintes sobre a mudança
  }
}
