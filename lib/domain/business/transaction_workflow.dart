import 'package:tech_challenge_fase3/data/api/transaction_api.dart';
import 'package:tech_challenge_fase3/domain/models/transaction_model.dart';

class TransactionWorkflow {
  final TransactionApi _api;

  TransactionWorkflow(this._api);

  Future<void> executeTransaction({
    required String userId,
    required String type,
    required String amount,
    required double currentBalance,
    required Function(double newBalance) onBalanceUpdated,
  }) async {
    final valor = double.tryParse(amount.replaceAll(',', '.')) ?? 0;
    if (valor <= 0) throw Exception('Valor deve ser maior que zero');

    final newBalance = _calculateNewBalance(currentBalance, valor, type);
    if (newBalance < 0) throw Exception('Saldo insuficiente');

    await _api.addTransaction(type: type, amount: amount);
    await _api.updateUserBalance(userId, newBalance);

    onBalanceUpdated(newBalance);
  }

  double _calculateNewBalance(
    double currentBalance,
    double amount,
    String type,
  ) {
    return (type == 'Saque' || type == 'Transferência')
        ? currentBalance - amount
        : currentBalance + amount;
  }
}
