import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_challenge_fase3/models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  StreamSubscription? _transactionSubscription;

  List<TransactionModel> get transactions => _transactions;
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
                querySnapshot.docs
                    .map(
                      (doc) => TransactionModel.fromMap(
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .toList();

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
