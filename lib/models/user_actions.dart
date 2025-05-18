class UpdateUserAction {
  final String? uid;
  final String displayName;
  final double balance;

  UpdateUserAction({
    this.uid,
    required this.displayName,
    required this.balance,
  });
}