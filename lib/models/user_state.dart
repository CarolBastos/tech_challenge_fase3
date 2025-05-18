class UserState {
  final String? uid;
  final String displayName;
  final double balance;

  UserState({
    this.uid,
    this.displayName = "Usuário",
    this.balance = 0.0,
  });

  UserState copyWith({
    String? uid,
    String? displayName,
    double? balance,
  }) {
    return UserState(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      balance: balance ?? this.balance,
    );
  }
}