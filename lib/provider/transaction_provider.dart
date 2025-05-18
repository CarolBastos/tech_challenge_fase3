import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tech_challenge_fase3/app_state.dart';
import 'package:tech_challenge_fase3/domain/business/transaction_workflow.dart';
import 'package:tech_challenge_fase3/domain/models/transaction_model.dart';
import 'package:tech_challenge_fase3/domain/models/user_actions.dart';
import 'package:tech_challenge_fase3/data/api/transaction_api.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionApi _api = TransactionApi();
  late final TransactionWorkflow _workflow;

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  StreamSubscription? _transactionSubscription;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  TransactionProvider() {
    _workflow = TransactionWorkflow(_api);
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
    _transactionSubscription = _api
        .listenToUserTransactions(userId)
        .listen(
          (transactions) {
            _transactions = transactions;
            _isLoading = false;
            notifyListeners();
          },
          onError: (_) {
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

      await _workflow.executeTransaction(
        userId: user.uid,
        type: type,
        amount: amount,
        currentBalance: store.state.userState.balance,
        onBalanceUpdated: (newBalance) {
          store.dispatch(
            UpdateUserAction(
              uid: user.uid,
              displayName: store.state.userState.displayName,
              balance: newBalance,
            ),
          );
        },
      );

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

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
