import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:tech_challenge_fase3/provider/transaction_provider.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/transaction_list/transaction_list_view.dart';

class TransactionListFiltered extends StatelessWidget {
  final DateTime? data;
  final double? valor;
  final String? tipoTransferencia;

  const TransactionListFiltered({
    this.data,
    this.valor,
    this.tipoTransferencia,
  });

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;

    final transacoesFiltradas =
        transactions.where((transacao) {
          bool matchesData =
              data == null ||
              (transacao.data.year == data!.year &&
                  transacao.data.month == data!.month &&
                  transacao.data.day == data!.day);

          bool matchesValor = valor == null || transacao.valor == valor;
          bool matchesTipo =
              tipoTransferencia == null || transacao.tipo == tipoTransferencia;

          return matchesData && matchesValor && matchesTipo;
        }).toList();

    return TransactionListView(transactions: transacoesFiltradas);
  }
}
