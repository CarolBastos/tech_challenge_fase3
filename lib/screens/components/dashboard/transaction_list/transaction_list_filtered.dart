import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tech_challenge_fase3/provider/transaction_provider.dart';
import 'package:tech_challenge_fase3/screens/components/dashboard/new_transaction/edit_transaction.dart';
import 'package:tech_challenge_fase3/models/transaction_model.dart';

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

    // Filtra as transações com base nos parâmetros fornecidos
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

    return Column(
      children:
          transacoesFiltradas.map((transacao) {
            return GestureDetector(
              onTap: () {
                _openEditTransactionDialog(context, transacao);
              },
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    transacao.tipo,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Valor: ${transacao.valor.toStringAsFixed(2)}\nData: ${DateFormat('dd/MM/yyyy').format(transacao.data)}',
                  ),
                  trailing: Icon(Icons.edit),
                ),
              ),
            );
          }).toList(),
    );
  }

  // Método para abrir o diálogo de edição
  void _openEditTransactionDialog(
    BuildContext context,
    TransactionModel transacao,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: EditTransaction(
            data: transacao.data,
            tipoTransacao: transacao.tipo,
            valor: transacao.valor.toString(),
          ),
        );
      },
    );
  }
}
