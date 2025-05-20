import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_challenge_fase3/utils/generate_key.dart';

class UserApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUserIfNotExists() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('usuarios').doc(user.uid);
    final userDoc = await userRef.get();

    final encryptedName = await encryptText(user.displayName ?? '');
    final encryptedEmail = await encryptText(user.email ?? '');

    if (!userDoc.exists) {
      await userRef.set({
        'nome': encryptedName,
        'email': encryptedEmail,
        'saldo': 0.0,
        'criado_em': FieldValue.serverTimestamp(),
      });
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
