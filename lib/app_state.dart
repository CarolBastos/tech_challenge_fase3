import 'package:tech_challenge_fase3/domain/models/user_reducer.dart';
import 'package:tech_challenge_fase3/domain/models/user_state.dart';

class AppState {
  final UserState userState;

  AppState({required this.userState});

  factory AppState.initial() {
    return AppState(userState: UserState());
  }

  // Método para serialização (toJson)
  Map<String, dynamic> toJson() {
    return {
      'userState': userState.toJson(),
    };
  }

  // Factory method para desserialização (fromJson)
  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      userState: UserState.fromJson(json['userState'] as Map<String, dynamic>),
    );
  }

  // Método copyWith para facilitar atualizações
  AppState copyWith({
    UserState? userState,
  }) {
    return AppState(
      userState: userState ?? this.userState,
    );
  }
}

AppState appReducer(AppState state, dynamic action) {
  return AppState(userState: userReducer(state.userState, action));
}