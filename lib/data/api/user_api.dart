// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:redux/redux.dart';
import 'package:tech_challenge_fase3/app_state.dart';
import 'package:tech_challenge_fase3/domain/models/user_actions.dart';

class UserApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Store<AppState> store;

  UserApi(this.store);

  Future<void> syncUserWithRedux() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final balance = await getUserBalance();
    
    store.dispatch(UpdateUserAction(
      uid: user.uid,
      displayName: user.displayName ?? 'Usuário',
      balance: balance,
    ));
  }

  Future<void> createUserIfNotExists() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('usuarios').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      await userRef.set({
        'nome': user.displayName ?? '',
        'email': user.email,
        'saldo': 0.0,
        'criado_em': FieldValue.serverTimestamp(),
      });
      
      // Atualiza o estado do Redux
      store.dispatch(UpdateUserAction(
        uid: user.uid,
        displayName: user.displayName ?? 'Usuário',
        balance: 0.0,
      ));
    }
  }

  Future<double> getUserBalance() async {
    final user = _auth.currentUser;
    if (user == null) return 0.0;

    final userRef = _firestore.collection('usuarios').doc(user.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      return (userDoc['saldo'] ?? 0.0).toDouble();
    }

    return 0.0;
  }

  Future<double> getUserBalanceEditTransaction(String uid) async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();

    return (doc['saldo'] ?? 0).toDouble();
  }
}
