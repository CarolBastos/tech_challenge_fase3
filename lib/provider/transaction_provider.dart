// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_challenge_fase3/app_state.dart';
import 'package:tech_challenge_fase3/models/transaction_model.dart';
import 'package:tech_challenge_fase3/models/user_actions.dart';

import 'package:flutter_redux/flutter_redux.dart';

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
            _transactions = querySnapshot.docs
                .map((doc) => TransactionModel.fromMap(doc.data()))
                .toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> addTransaction({
    required BuildContext context,
    required String type,
    required String amount,
  }) async {
    try {
      final store = StoreProvider.of<AppState>(context);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final valor = double.tryParse(amount.replaceAll(',', '.')) ?? 0;
      if (valor <= 0) throw Exception('Valor deve ser maior que zero');

      final currentBalance = store.state.userState.balance;
      final newBalance = _calculateNewBalance(currentBalance, valor, type);

      if (newBalance < 0) throw Exception('Saldo insuficiente');

      // Adiciona a transação no Firestore
      await FirebaseFirestore.instance.collection('transacoes').add({
        'user_id': user.uid,
        'tipo': type,
        'valor': amount, // Mantém como string para consistência
        'data': FieldValue.serverTimestamp(),
      });

      // Atualiza o saldo no Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({'saldo': newBalance});

      // Atualiza o estado no Redux
      store.dispatch(UpdateUserAction(
        uid: user.uid,
        displayName: store.state.userState.displayName,
        balance: newBalance,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transação concluída com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      throw e;
    }
  }

  double _calculateNewBalance(double currentBalance, double amount, String type) {
    return (type == 'Saque' || type == 'Transferência')
        ? currentBalance - amount
        : currentBalance + amount;
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}