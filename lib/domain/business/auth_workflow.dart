import 'package:firebase_auth/firebase_auth.dart';

class AuthWorkflow {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();
    }
  }
}
