// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:redux/redux.dart';
import 'package:tech_challenge_fase3/app_state.dart';
import 'package:tech_challenge_fase3/data/api/user_api.dart';
import 'package:tech_challenge_fase3/domain/models/user_actions.dart';

class AuthWorkflow {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Store<AppState> store;

  AuthWorkflow(this.store);

  Future<void> login({
    required String email, 
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Sincroniza os dados do usuário após login
    if (userCredential.user != null) {
      final userApi = UserApi(store);
      await userApi.createUserIfNotExists();
      await userApi.syncUserWithRedux();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();

      // Sincroniza os dados do usuário após registro
      final userApi = UserApi(store);
      await userApi.createUserIfNotExists();
      await userApi.syncUserWithRedux();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    // Opcional: dispatch action para limpar o estado do usuário
    store.dispatch(UpdateUserAction(
      uid: null,
      displayName: 'Usuário',
      balance: 0.0,
    ));
  }
}