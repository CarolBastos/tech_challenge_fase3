import 'package:tech_challenge_fase3/models/user_actions.dart';
import 'package:tech_challenge_fase3/models/user_state.dart';

UserState userReducer(UserState state, dynamic action) {
  if (action is UpdateUserAction) {
    return state.copyWith(
      uid: action.uid,
      displayName: action.displayName,
      balance: action.balance,
    );
  }
  return state;
}