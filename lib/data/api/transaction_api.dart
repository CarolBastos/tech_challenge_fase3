import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_challenge_fase3/models/transaction_model.dart';

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
}
