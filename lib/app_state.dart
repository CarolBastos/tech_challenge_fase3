import 'package:tech_challenge_fase3/domain/models/user_reducer.dart';
import 'package:tech_challenge_fase3/domain/models/user_state.dart';

class AppState {
  final UserState userState;

  AppState({required this.userState});

  factory AppState.initial() {
    return AppState(userState: UserState());
  }
}

AppState appReducer(AppState state, dynamic action) {
  return AppState(userState: userReducer(state.userState, action));
}
