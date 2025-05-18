import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_challenge_fase3/domain/models/transaction_model.dart';

class TransactionApi {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<List<TransactionModel>> listenToUserTransactions(String userId) {
    return _firestore
        .collection('transacoes')
        .where('user_id', isEqualTo: userId)
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (query) =>
              query.docs
                  .map((doc) => TransactionModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  Future<void> addTransaction({
    required String type,
    required String amount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final valor = double.tryParse(amount.replaceAll(',', '.')) ?? 0;
    if (valor <= 0) throw Exception('Valor deve ser maior que zero');

    await _firestore.collection('transacoes').add({
      'user_id': user.uid,
      'tipo': type,
      'valor': amount,
      'data': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserBalance(String userId, double newBalance) async {
    await _firestore.collection('usuarios').doc(userId).update({
      'saldo': newBalance,
    });
  }

  Future<void> editTransaction({
    required DateTime date,
    required String newType,
    required String newValue,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final valorNumerico = double.tryParse(newValue.replaceAll(',', '.')) ?? 0;
    if (valorNumerico <= 0) throw Exception('Valor deve ser maior que zero');

    final querySnapshot =
        await _firestore
            .collection('transacoes')
            .where('user_id', isEqualTo: user.uid)
            .where('data', isEqualTo: Timestamp.fromDate(date))
            .limit(1)
            .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Transação não encontrada');
    }

    final transactionDoc = querySnapshot.docs.first;
    final valorAntigo =
        double.tryParse(transactionDoc['valor'].replaceAll(',', '.')) ?? 0;

    await transactionDoc.reference.update({'tipo': newType, 'valor': newValue});

    final userDoc = await _firestore.collection('usuarios').doc(user.uid).get();
    double saldoAtual = (userDoc['saldo'] ?? 0).toDouble();

    saldoAtual += valorAntigo;

    saldoAtual = _calculateNewBalance(saldoAtual, valorNumerico, newType);

    await updateUserBalance(user.uid, saldoAtual);
  }

  bool _isNegativeTransaction(String type) {
    return type == 'Saque' || type == 'Transferência';
  }

  double _calculateNewBalance(
    double currentBalance,
    double amount,
    String type,
  ) {
    return _isNegativeTransaction(type)
        ? currentBalance - amount
        : currentBalance + amount;
  }
}
