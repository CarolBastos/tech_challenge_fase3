import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
}
