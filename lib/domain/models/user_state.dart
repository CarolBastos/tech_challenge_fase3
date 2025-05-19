
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

  // Método para serialização (não precisa implementar Persistable)
 Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'balance': balance,
    };
  }

  factory UserState.fromJson(Map<String, dynamic> json) {
    return UserState(
      uid: json['uid'] as String?,
      displayName: json['displayName'] as String? ?? "Usuário",
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}