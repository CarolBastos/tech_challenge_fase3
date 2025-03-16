import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionProvider with ChangeNotifier {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  StreamSubscription? _transactionSubscription;

  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;

  TransactionProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print("Usuário autenticado? ${user != null}");

      if (user != null) {
        _listenToTransactions(user.uid);
      } else {
        _transactions = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _listenToTransactions(String userId) {
    print("Buscando transações para o usuário: $userId");
    _isLoading = true;
    notifyListeners();

    _transactionSubscription?.cancel();

    _transactionSubscription = FirebaseFirestore.instance
        .collection('transacoes')
        .where('user_id', isEqualTo: userId)
        .orderBy('data', descending: true)
        .snapshots()
        .listen(
          (querySnapshot) {
            print("Foram encontradas ${querySnapshot.docs.length} transações");

            _transactions =
                querySnapshot.docs.map((doc) {
                  return {
                    'data': (doc['data'] as Timestamp).toDate(),
                    'tipo': doc['tipo'],
                    'valor': double.tryParse(doc['valor'].toString()) ?? 0.0,
                  };
                }).toList();

            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            print("Erro ao buscar transações: $error");
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
